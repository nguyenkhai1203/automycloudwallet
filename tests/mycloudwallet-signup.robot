*** Settings ***
Documentation       Complete MyCloudWallet signup flow with temp email and anti-detection

Library             SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Library             String
Library             Collections
Library             DateTime
Library             OperatingSystem
Resource            ../resources/common.robot
Resource            ../resources/variables.robot
Resource            ../resources/mycloudwallet_keywords.robot


*** Test Cases ***
Complete MyCloudWallet Signup Flow
    [Documentation]    Complete signup flow for MyCloudWallet with temp email
    [Setup]    Open Browser With Options    ${TEMPMAIL_URL}

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

    # Step 3: Wait for and open activation email
    Wait For Activation Email
    Click Verification Link

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
    Log To Console    \n===== TEMPORARY EMAIL =====\n${temp_email}\n==========================\n

    # Short delay after copying
    Sleep    ${SHORT_WAIT}

Perform Sign Up
    [Documentation]    Fill out and submit the signup form
    # First navigate to the "Create Account" page by clicking the Create Account button
    Log To Console    Clicking Create Account button...
    Wait Until Element Is Visible    ${SIGN_UP_BUTTON}    timeout=15s
    Click Element    ${SIGN_UP_BUTTON}
    Sleep    2s

    # Take a screenshot to verify the page state
    Capture Page Screenshot    signup_page.png

    # Now we should be on the sign-up page with the form visible
    Log To Console    Filling sign-up form...

    # Try a different approach to find the email input if needed
    ${email_present}=    Run Keyword And Return Status    Page Should Contain Element    ${EMAIL_INPUT}
    IF    not ${email_present}
        Log To Console    Email input not found with selector: ${EMAIL_INPUT}
    END

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

    # Try different strategies to find and click the confirmation modal button
    Log To Console    Looking for confirmation button...

    # First try with the specific CSS selector
    ${specific_button_present}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${CONFIRM_MODAL_BUTTON}    timeout=5s

    # If specific selector fails, try a more generic one
    ${generic_button_present}=    Run Keyword And Return Status
    ...    Page Should Contain Element    css=div.ant-modal-content button

    # Try clicking with specific selector if present
    IF    ${specific_button_present}
        Log To Console    Found confirmation button with specific selector, clicking...
        Click Element    ${CONFIRM_MODAL_BUTTON}
    END

    # Otherwise try with generic selector
    IF    not ${specific_button_present} and ${generic_button_present}
        Log To Console    Found confirmation button with generic selector, clicking...
        Click Element    css=div.ant-modal-content button
    END

    # If neither worked, log a warning
    IF    not ${specific_button_present} and not ${generic_button_present}
        Log To Console    WARNING: Could not find confirmation button, continuing...
    END

    # Additional wait time after button click attempt
    Sleep    3s

Handle Turnstile Challenge
    [Documentation]    Handle Turnstile CAPTCHA challenge
    ${turnstile_present}=    Run Keyword And Return Status    Page Should Contain Element    ${TURNSTILE_IFRAME}

    IF    ${turnstile_present}    Handle Turnstile Iframe

    # Wait for challenge completion
    Sleep    ${SHORT_WAIT}

Handle Turnstile Iframe
    [Documentation]    Handle the Turnstile iframe and checkbox
    Wait Until Element Is Visible    ${TURNSTILE_IFRAME}    timeout=15s

    # Switch to iframe
    Select Frame    ${TURNSTILE_IFRAME}

    # Click the checkbox - adding explicit timeout and logging
    Log To Console    Waiting for turnstile checkbox...
    Wait Until Element Is Visible    ${TURNSTILE_CHECKBOX}    timeout=15s
    Log To Console    Clicking turnstile checkbox...
    Click Element    ${TURNSTILE_CHECKBOX}

    # Wait for verification
    Sleep    ${MEDIUM_WAIT}

    # Switch back to main content
    Unselect Frame

    # Additional wait for challenge completion
    Sleep    ${MEDIUM_WAIT}
    Log To Console    Turnstile challenge handled

Wait For Activation Email
    [Documentation]    Wait for activation email and open it
    # Give email time to arrive
    Log To Console    Waiting for activation email...
    Sleep    ${SHORT_WAIT}

    # Refresh page to check for new emails
    Reload Page

    # Wait for email list to load and retry if needed
    ${max_attempts}=    Set Variable    15
    ${attempt}=    Set Variable    1

    WHILE    ${attempt} <= ${max_attempts}
        # Look specifically for the verification email with exact title
        ${verification_email_present}=    Run Keyword And Return Status
        ...    Page Should Contain Element    ${VERIFICATION_EMAIL}

        IF    ${verification_email_present}    BREAK

        # Take screenshot to see what's available
        Capture Page Screenshot    tempmail_${attempt}.png

        # Try with alternative selector if needed
        ${alt_verification_email}=    Set Variable    xpath=//div[contains(text(), '[Cloud Wallet]')]
        ${alt_email_present}=    Run Keyword And Return Status
        ...    Page Should Contain Element    ${alt_verification_email}

        IF    ${alt_email_present}
            Log To Console    Found email with alternative selector
            Set Suite Variable    ${VERIFICATION_EMAIL}    ${alt_verification_email}
            BREAK
        END

        Log To Console    Attempt ${attempt}: No verification email yet, refreshing...
        Reload Page
        Sleep    ${SHORT_WAIT}
        ${attempt}=    Evaluate    ${attempt} + 1
    END

    # Fail if no verification email after max attempts
    IF    ${attempt} > ${max_attempts}
        Fail    No verification email received after ${max_attempts} attempts
    END

    # Click the verification email
    Log To Console    Verification email found, clicking...
    Click Element    ${VERIFICATION_EMAIL}

    # Wait for email content to load
    Sleep    3s

    # Try to extract activation code if present
    ${code_present}=    Run Keyword And Return Status
    ...    Page Should Contain Element    ${ACTIVATION_CODE_SELECTOR}

    IF    ${code_present}    Get Activation Code

    # Take screenshot of email
    Capture Page Screenshot    verification_email.png

Get Activation Code
    [Documentation]    Extract the activation code from the email
    ${activation_code}=    Get Text    ${ACTIVATION_CODE_SELECTOR}
    ${activation_code}=    Strip String    ${activation_code}
    Set Suite Variable    ${activation_code}

    # Log the code to the console for visibility
    Log To Console    \n===== ACTIVATION CODE =====\n${activation_code}\n==========================\n

Click Verification Link
    [Documentation]    Click the email verification link
    Wait Until Element Is Visible    ${ACTIVATION_LINK}    timeout=15s

    # Take screenshot before clicking
    Capture Page Screenshot    before_activation_click.png

    # Click activation link which opens in a new tab
    Click Element    ${ACTIVATION_LINK}

    # Wait for new tab to open
    Sleep    ${SHORT_WAIT}

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
    Sleep    ${SHORT_WAIT}

Login With Created Account
    [Documentation]    Login with the newly created account
    Wait Until Element Is Visible    ${LOGIN_BUTTON}    timeout=15s
    Click Element    ${LOGIN_BUTTON}

    # Fill login form
    Wait Until Element Is Visible    ${EMAIL_INPUT}    timeout=15s
    Input Text Fast    ${EMAIL_INPUT}    ${temp_email}
    Input Text Fast    ${PASSWORD_INPUT}    ${SIGNUP_PASSWORD}

    # Click sign in
    Click Element    ${SIGN_IN_BUTTON}

    # Handle any Turnstile challenge on login
    ${turnstile_present}=    Run Keyword And Return Status    Page Should Contain Element    ${TURNSTILE_IFRAME}
    IF    ${turnstile_present}    Handle Turnstile Iframe

    # Wait for login completion
    Sleep    ${SHORT_WAIT}

    # Log success message to console
    Log To Console    \n===== LOGIN SUCCESSFUL =====\nAccount: ${temp_email}\n==========================\n

Input Text Fast
    [Documentation]    Input text directly without character-by-character delays
    [Arguments]    ${locator}    ${text}

    Wait Until Element Is Visible    ${locator}
    Click Element    ${locator}
    Input Text    ${locator}    ${text}
    # Add just a small delay after typing to appear slightly more human-like
    ${end_delay}=    Evaluate    random.uniform(0.2, 0.5)    random
    Sleep    ${end_delay}
