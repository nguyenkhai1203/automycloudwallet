*** Settings ***
Library    SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Resource    ../resources/common.robot
Resource    ../resources/variables.robot
Suite Setup    Open Browser With Options    ${TEMPMAIL_URL}
Suite Teardown    Close All Browsers Gracefully

*** Variables ***
${SIGNUP_PASSWORD}    qwertyuiO.1

*** Test Cases ***
Sign Up and Activate Account
    [Documentation]    Automate sign-up with email activation
    Get Temp Email
    Open New Tab To Mycloudwallet
    Switch To Mycloudwallet Tab
    Perform Sign Up
    Handle Captcha
    Check Sign Up Success
    Switch To Tempmail Tab
    Wait For Activation Email
    Get Activation URL
    Switch To Mycloudwallet Tab
    Activate Account

*** Keywords ***
Get Temp Email
    [Documentation]    Retrieve the temporary email by finding and clicking the Copy button
    Sleep    10s                                    # Wait for page load
    Wait Until Element Is Visible    ${TEMP_EMAIL_LOCATOR} # Ensure Copy button is ready
    ${result}    ${error}=    Run Keyword And Ignore Error    Get Text    ${TEMP_EMAIL_LOCATOR}
    Log To Console    Error: ${error}
    ${temp_email}=    Get Text    ${TEMP_EMAIL_LOCATOR}  # Get email from text-base truncate class
    # Click Element    ${COPY_BUTTON}                 # Click Copy button as requested
    Set Suite Variable    ${temp_email}             # Save email to variable
    Log To Console    -----temp_email: ${temp_email}  # Log the value
Open New Tab To Mycloudwallet
    Open New Tab To URL    ${MYCLOUDWALLET_URL}

Switch To Mycloudwallet Tab
    Switch To Tab    1

Switch To Tempmail Tab
    Switch To Tab    0

Perform Sign Up
    Click Element    ${SIGN_UP_BUTTON}
    Input Text       ${EMAIL_FIELD}            ${temp_email}
    Input Text       ${PASSWORD_FIELD}         ${SIGNUP_PASSWORD}
    Input Text       ${CONFIRM_PASSWORD_FIELD}    ${SIGNUP_PASSWORD}
    Click Element    ${SIGN_UP_SUBMIT}

Check Sign Up Success
    Wait Until Element Is Visible    ${SUCCESS_POPUP}    timeout=${PAGE_LOAD_TIME}

Wait For Activation Email
    Wait Until Element Is Visible    ${EMAIL_LIST}    timeout=30s
    Click Element    ${EMAIL_LIST}:nth-child(1)

Get Activation URL
    ${activation_url}=    Get Element Attribute    ${ACTIVATION_LINK}    href
    Set Suite Variable    ${activation_url}

Activate Account
    Go To    ${activation_url}
    Wait Until Page Contains    Account activated    timeout=${PAGE_LOAD_TIME}  # Adjust based on actual message