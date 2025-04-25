*** Settings ***
Library             SeleniumLibrary
Library             String
Library             Collections
Library             DateTime
Resource            ../resources/common.robot
Resource            ../resources/variables.robot

*** Test Cases ***
MyCloudWallet Signup
    [Setup]    Open Browser With Options    ${TEMPMAIL_URL}
    
    # Get email
    Wait Until Element Is Visible    css=div.cursor-pointer span.text-base.truncate    timeout=15s
    ${temp_email}=    Get Text    css=div.cursor-pointer span.text-base.truncate
    Set Suite Variable    ${temp_email}
    
    # Go to signup page
    Open New Tab To URL    ${MYCLOUDWALLET_URL}
    Switch To Tab    1
    Wait Until Element Is Visible    ${SIGN_UP_BUTTON}    timeout=15s
    Click Element    ${SIGN_UP_BUTTON}
    Sleep    2s
    
    # Fill signup form
    Wait Until Element Is Visible    ${EMAIL_INPUT}    timeout=15s
    Input Text    ${EMAIL_INPUT}    ${temp_email}
    Input Text    ${PASSWORD_INPUT}    ${SIGNUP_PASSWORD}
    Input Text    ${CONFIRM_PASSWORD_INPUT}    ${SIGNUP_PASSWORD}
    Click Element    ${SIGN_UP_SUBMIT_BUTTON}
    Sleep    3s
    
    # Click OK if confirmation appears
    ${ok_exists}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//button[@type='button' and @class='ant-btn ant-btn-default']/span[text()='ok']    timeout=5s
    Run Keyword If    ${ok_exists}    Click Element    xpath=//button[@type='button' and @class='ant-btn ant-btn-default']/span[text()='ok']
    Sleep    2s
    
    # Handle Turnstile if present
    Handle Turnstile If Present
    
    # Go back to email tab
    Switch To Tab    0
    Sleep    15s
    Reload Page
    Sleep    2s
    
    # Open verification email
    ${email_exists}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//div[contains(text(), 'Cloud Wallet')]
    Run Keyword If    ${email_exists}    Click Element    xpath=//div[contains(text(), 'Cloud Wallet')]
    ...    ELSE    Click Element    css=.email-item:first-child
    Sleep    3s
    
    # Click verification link
    ${link_by_text1}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//a[text()='Verify your Account']
    ${link_by_text2}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//a[contains(text(), 'Verify') and contains(text(), 'Account')]
    ${link_by_purple}=    Run Keyword And Return Status    Element Should Be Visible    css=a[style*='background:#8549B6'], a[style*='background: #8549B6']
    ${link_by_url}=    Run Keyword And Return Status    Element Should Be Visible    css=a[href*='verify?token']
    
    Run Keyword If    ${link_by_text1}    Click Element    xpath=//a[text()='Verify your Account']
    ...    ELSE IF    ${link_by_text2}    Click Element    xpath=//a[contains(text(), 'Verify') and contains(text(), 'Account')]
    ...    ELSE IF    ${link_by_purple}    Click Element    css=a[style*='background:#8549B6'], a[style*='background: #8549B6'] 
    ...    ELSE IF    ${link_by_url}    Click Element    css=a[href*='verify?token']
    ...    ELSE    Extract And Open Verification URL
    Sleep    3s
    
    # Handle activation page
    ${handles}=    Get Window Handles
    Switch Window    ${handles}[-1]
    Wait Until Page Contains    Account activated    timeout=15s
    Wait Until Element Is Visible    ${CONTINUE_BUTTON}    timeout=15s
    Click Element    ${CONTINUE_BUTTON}
    Sleep    3s
    
    # Login with created account
    Wait Until Element Is Visible    ${LOGIN_BUTTON}    timeout=15s
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${EMAIL_INPUT}    timeout=15s
    Input Text    ${EMAIL_INPUT}    ${temp_email}
    Input Text    ${PASSWORD_INPUT}    ${SIGNUP_PASSWORD}
    Click Element    ${SIGN_IN_BUTTON}
    Sleep    3s
    
    # Handle Turnstile again if present
    Handle Turnstile If Present
    
    [Teardown]    Close All Browsers

*** Keywords ***
Extract And Open Verification URL
    ${page_source}=    Get Source
    ${url_pattern}=    Set Variable    https://login-api.mycloudwallet.com/v1/register/verify\\?token=[a-zA-Z0-9]+
    ${contains_url}=    Run Keyword And Return Status    Should Match Regexp    ${page_source}    ${url_pattern}
    
    IF    ${contains_url}
        ${matches}=    Get Regexp Matches    ${page_source}    ${url_pattern}
        Open Browser    ${matches}[0]    chrome    alias=verification_window
    END

Handle Turnstile If Present
    ${turnstile_present}=    Run Keyword And Return Status    Page Should Contain Element    ${TURNSTILE_IFRAME}
    
    IF    ${turnstile_present}
        Wait Until Element Is Visible    ${TURNSTILE_IFRAME}    timeout=15s
        Select Frame    ${TURNSTILE_IFRAME}
        Wait Until Element Is Visible    ${TURNSTILE_CHECKBOX}    timeout=15s
        Click Element    ${TURNSTILE_CHECKBOX}
        Sleep    3s
        Unselect Frame
        Sleep    3s
    END