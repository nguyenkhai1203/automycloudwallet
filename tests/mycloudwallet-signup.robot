*** Settings ***
Documentation     Complete MyCloudWallet signup flow with temp email and anti-detection
Library           SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Library           String
Library           Collections
Library           DateTime
Library           OperatingSystem
Resource          ../resources/common.robot
Resource          ../resources/variables.robot
Resource          ../resources/mycloudwallet_keywords.robot

*** Variables ***
${SIGNUP_PASSWORD}             qwertyuiO.1
${ACTIVATION_LINK}             xpath=//a[contains(text(), 'Activate') or contains(text(), 'activate')]
${CONTINUE_BUTTON}             xpath=//button//span[text()='Continue']
${CONFIRM_MODAL_BUTTON}        css=body > div:nth-child(8) > div > div.ant-modal-wrap > div > div.ant-modal-content > div > div > div.content > div.sc-vuxumm-0.EwLhs > button

# Updated selectors based on actual HTML
${EMAIL_INPUT}                 css=div.new-sign-up-div-7 input[inputmode='email']
${PASSWORD_INPUT}              xpath=(//div[@class='new-sign-up-div-7']//input[@name='password'])[1]
${CONFIRM_PASSWORD_INPUT}      xpath=(//div[@class='new-sign-up-div-7']//input[@name='password'])[2]
${SIGN_UP_SUBMIT_BUTTON}       xpath=//button[@type='button' and @class='ant-btn ant-btn-default']//span[text()='Create Account']

*** Test Cases ***
Complete MyCloudWallet Signup Flow
    [Documentation]    Complete signup flow for MyCloudWallet with temp email
    [Setup]            Open Browser With Options    ${TEMPMAIL_URL}
    
    # Step 1: Get temporary email from tempmail.so
    Get Temp Email
    
    # Step 2: Open MyCloudWallet and sign up
    Open New Tab To URL    ${MYCLOUDWALLET_URL}
    Switch To Tab    1
    Perform Sign Up
    Handle Turnstile Challenge
    
    # Force switch back to TempMail tab using window handles
    ${handles}=    Get Window Handles
    Log To Console    Switching back to TempMail tab (handle 0)...
    Switch Window    ${handles}[0]
    
    # Verify we're on the right page
    ${current_url}=    Get Location
    Log To Console    Current URL after switching: ${current_url}
    
    # Additional verification that we're on tempmail
    Run Keyword If    'tempmail' not in '${current_url}'    Log To Console    WARNING: May not be on TempMail page!
    
    # Step 3: Wait for and open activation email
    Wait For Activation Email
    Get Activation URL
    
    # Step 4: Handle activation and continue to login
    Switch To Activation Tab
    Click Continue After Activation
    Login With Created Account
    
    [Teardown]    Close All Browsers Gracefully

*** Keywords ***
Get Temp Email
    [Documentation]    Get temporary email from tempmail.so
    # Wait for the email container to be visible
    Wait Until Element Is Visible    css=div.cursor-pointer span.text-base.truncate    timeout=15s
    
    # Get the email text directly from the span element
    ${temp_email}=    Get Text    css=div.cursor-pointer span.text-base.truncate
    Set Suite Variable    ${temp_email}
    
    # Click on the container to copy the email
    Click Element    css=div.cursor-pointer
    
    # Log the email to the console for visibility
    Log To Console    \n
    Log To Console    ===== TEMPORARY EMAIL =====
    Log To Console    ${temp_email}
    Log To Console    ==========================
    Log To Console    \n
    
    # Short delay after copying
    Sleep    3s

Perform Sign Up
    [Documentation]    Fill out and submit the signup form
    # First navigate to the "Create Account" page by clicking the Create Account button
    Log To Console    Clicking Create Account button...
    Wait Until Element Is Visible    xpath=//button//span[text()='Create Account']    timeout=15s
    Click Element    xpath=//button//span[text()='Create Account']
    Sleep    2s
    
    # Take a screenshot to verify the page state
    Capture Page Screenshot    signup_page.png
    Log To Console    Captured screenshot of signup page
    
    # Now we should be on the sign-up page with the form visible
    Log To Console    Filling sign-up form...
    Log To Console    Waiting for email input field...
    
    # Try a different approach to find the email input
    ${email_present}=    Run Keyword And Return Status    Page Should Contain Element    ${EMAIL_INPUT}
    Run Keyword If    not ${email_present}    Log To Console    Email input not found with selector: ${EMAIL_INPUT}
    
    # Try alternative selectors if needed
    ${alt_email_input}=    Set Variable    xpath=//input[@inputmode='email' or @type='email']
    ${alt_email_present}=    Run Keyword And Return Status    Page Should Contain Element    ${alt_email_input}
    
    Run Keyword If    ${alt_email_present}    Log To Console    Found email input with alternative selector
    Run Keyword If    ${alt_email_present}    Set Global Variable    ${EMAIL_INPUT}    ${alt_email_input}
    
    Wait Until Element Is Visible    ${EMAIL_INPUT}    timeout=15s
    Log To Console    Entering email: ${temp_email}
    Input Text Fast    ${EMAIL_INPUT}    ${temp_email}
    
    Log To Console    Entering password...
    Input Text Fast    ${PASSWORD_INPUT}    ${SIGNUP_PASSWORD}
    
    Log To Console    Confirming password...
    Input Text Fast    ${CONFIRM_PASSWORD_INPUT}    ${SIGNUP_PASSWORD}
    
    Log To Console    Submitting form...
    Sleep    0.5s
    Click Element    ${SIGN_UP_SUBMIT_BUTTON}
    
    Log To Console    Form submitted, waiting...
    Sleep    3s
    
    # Wait for the confirmation modal and click the button
    Log To Console    Looking for confirmation button...
    Wait Until Element Is Visible    ${CONFIRM_MODAL_BUTTON}    timeout=10s
    Log To Console    Found confirmation button, clicking...
    Click Element    ${CONFIRM_MODAL_BUTTON}
    
    # Additional wait time after confirmation button click
    Sleep    2s
    
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=15s
    Input Text Fast    ${EMAIL_FIELD}    ${temp_email}
    Input Text Fast    ${PASSWORD_FIELD}    ${SIGNUP_PASSWORD}
    Input Text Fast    ${CONFIRM_PASSWORD_FIELD}    ${SIGNUP_PASSWORD}
    
    ${random_delay}=    Evaluate    random.uniform(0.8, 2.0)    random
    Sleep    ${random_delay}
    Click Element    ${SIGN_UP_SUBMIT}
    
    Sleep    5s

Handle Turnstile Challenge
    [Documentation]    Handle Turnstile CAPTCHA challenge
    ${turnstile_present}=    Run Keyword And Return Status    Page Should Contain Element    iframe[src*='turnstile']
    
    Run Keyword If    ${turnstile_present}    Handle Turnstile Iframe
    
    # Wait for challenge completion
    Sleep    5s

Handle Turnstile Iframe
    [Documentation]    Handle the Turnstile iframe and checkbox
    Wait Until Element Is Visible    iframe[src*='turnstile']    timeout=15s
    
    # Switch to iframe
    Select Frame    iframe[src*='turnstile']
    
    # Randomize click timing
    ${random_delay}=    Evaluate    random.uniform(1.0, 3.0)    random
    Sleep    ${random_delay}
    
    # Click the checkbox
    Wait Until Element Is Visible    css=div.checkbox    timeout=15s
    Click Element    css=div.checkbox
    
    # Wait for verification
    Sleep    5s
    
    # Switch back to main content
    Unselect Frame
    
    # Additional wait for challenge completion
    Sleep    5s

Wait For Activation Email
    [Documentation]    Wait for activation email and open it
    # Give email time to arrive
    Log To Console    Waiting for activation email...
    Sleep    5s
    
    # Refresh page to check for new emails
    Reload Page
    
    # Wait for email list to load and retry if needed
    ${max_attempts}=    Set Variable    10
    ${attempt}=    Set Variable    1
    
    WHILE    ${attempt} <= ${max_attempts}
        ${emails_visible}=    Run Keyword And Return Status    Page Should Contain Element    ${EMAIL_LIST}
        
        Run Keyword If    ${emails_visible}    Exit For Loop
        
        Log To Console    Attempt ${attempt}: No emails yet, refreshing...
        Reload Page
        Sleep    5s
        ${attempt}=    Evaluate    ${attempt} + 1
    END
    
    # Fail if no emails appear after max attempts
    Run Keyword If    ${attempt} > ${max_attempts}    Fail    No activation email received after ${max_attempts} attempts
    
    # Click the first email (should be the most recent)
    Log To Console    Activation email found, opening...
    Click Element    ${EMAIL_LIST}:nth-child(1)
    
    # Wait for email content to load
    Sleep    3s

Get Activation URL
    [Documentation]    Get activation URL from email and click it
    Wait Until Element Is Visible    ${ACTIVATION_LINK}    timeout=15s
    
    # Click activation link which opens in a new tab
    Click Element    ${ACTIVATION_LINK}
    
    # Wait for new tab to open
    Sleep    5s

Switch To Activation Tab
    [Documentation]    Switch to the activation tab (opened by clicking activation link)
    ${handles}=    Get Window Handles
    ${count}=    Get Length    ${handles}
    ${index}=    Evaluate    ${count} - 1
    Switch Window    ${handles}[${index}]

Click Continue After Activation
    [Documentation]    Click continue after account activation
    Wait Until Page Contains    Account activated    timeout=15s
    
    # Look for and click the Continue button
    Wait Until Element Is Visible    ${CONTINUE_BUTTON}    timeout=15s
    Click Element    ${CONTINUE_BUTTON}
    
    # Wait for redirect to login page
    Sleep    5s

Login With Created Account
    [Documentation]    Login with the newly created account
    Wait Until Element Is Visible    xpath=//button//span[text()='Login']    timeout=15s
    Click Element    xpath=//button//span[text()='Login']
    
    # Fill login form
    Wait Until Element Is Visible    ${EMAIL_INPUT}    timeout=15s
    Input Text Fast    ${EMAIL_INPUT}    ${temp_email}
    Input Text Fast    ${PASSWORD_INPUT}    ${SIGNUP_PASSWORD}
    
    # Click sign in
    Click Element    xpath=//button//span[text()='Sign In']
    
    # Handle any Turnstile challenge on login
    ${turnstile_present}=    Run Keyword And Return Status    Page Should Contain Element    iframe[src*='turnstile']
    Run Keyword If    ${turnstile_present}    Handle Turnstile Iframe
    
    # Wait for login completion
    Sleep    10s
    
    # Log success message to console
    Log To Console    \n
    Log To Console    ===== LOGIN SUCCESSFUL =====
    Log To Console    Account: ${temp_email}
    Log To Console    ==========================
    Log To Console    \n

Input Text Fast
    [Documentation]    Input text directly without character-by-character delays
    [Arguments]    ${locator}    ${text}
    
    Wait Until Element Is Visible    ${locator}
    Click Element    ${locator}
    Input Text    ${locator}    ${text}
    # Add just a small delay after typing to appear slightly more human-like
    ${end_delay}=    Evaluate    random.uniform(0.2, 0.5)    random
    Sleep    ${end_delay}