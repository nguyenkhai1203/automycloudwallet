*** Settings ***
Library    SeleniumLibrary
Library    String
Library    Collections
Library    DateTime
Library    BuiltIn
Resource   common.robot

*** Variables ***
# Update these variables with your actual values
${URL}                      https://mycloudwallet.com
${USERNAME}                 khai.nguyen@opskins.com
${PASSWORD}                 qwertyuiO.1
${2FA_SECRET}               VRYXCWM5IZEDHOJR
${RECIPIENT_ADDRESS}        nguyenkhai12
${TRANSFER_AMOUNT}          0.001

# Locators - Update these with actual selectors from the site
${LOGIN_EMAIL_FIELD}        name=email
${LOGIN_PASSWORD_FIELD}     name=password
${LOGIN_BUTTON}             //span[text()='Login']
${TURNSTILE_CHECKBOX}       css=iframe[src*='turnstile']
${2FA_INPUT_FIELD}          css=input[placeholder*='code']
${2FA_SUBMIT_BUTTON}        css=button[type='submit']
${TRANSFER_MENU_OPTION}     css=a[href*='transfer']
${TOKEN_DROPDOWN}           css=select.token-select
${FIRST_TOKEN_OPTION}       css=select.token-select option:first-child
${RECIPIENT_ADDRESS_FIELD}  css=input[placeholder*='address']
${AMOUNT_FIELD}             css=input[type='number']
${SEND_BUTTON}              css=button:contains('Send')
${APPROVE_BUTTON}           css=button:contains('Approve')
${SUCCESS_TOAST}            css=div.toast-success

*** Keywords ***
Login To MyCloudWallet
    Wait Until Element Is Visible    ${LOGIN_EMAIL_FIELD}
    Input Text    ${LOGIN_EMAIL_FIELD}    ${USERNAME}
    Input Text    ${LOGIN_PASSWORD_FIELD}    ${PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    
    # Handle Turnstile captcha
    Handle Turnstile Captcha
    
    # Handle 2FA
    Enter 2FA Code
    
Wait For Page Load
    Wait Until Element Is Not Visible    css=div.loading    timeout=20s

Handle Turnstile Captcha
    Wait Until Element Is Visible    ${TURNSTILE_CHECKBOX}
    
    # Switch to captcha iframe
    Select Frame    ${TURNSTILE_CHECKBOX}
    Wait Until Element Is Visible    css=div.checkbox
    Click Element    css=div.checkbox
    Unselect Frame
    
    # Wait for captcha to be processed
    Sleep    3s

Enter 2FA Code
    # Generate TOTP code from secret
    ${totp_code}=    Generate TOTP Code    ${2FA_SECRET}
    
    Wait Until Element Is Visible    ${2FA_INPUT_FIELD}
    Input Text    ${2FA_INPUT_FIELD}    ${totp_code}
    Click Element    ${2FA_SUBMIT_BUTTON}
    
    Wait For Page Load

Generate TOTP Code
    [Arguments]    ${secret}
    # Use direct Python evaluation to generate TOTP
    ${totp_code}=    Evaluate    __import__('pyotp').TOTP('${secret}').now()
    [Return]    ${totp_code}

Navigate To Transfer Page
    Wait Until Element Is Visible    ${TRANSFER_MENU_OPTION}
    Click Element    ${TRANSFER_MENU_OPTION}
    Wait For Page Load

Select Token And Enter Transfer Details
    # Select first token from dropdown
    Wait Until Element Is Visible    ${TOKEN_DROPDOWN}
    Click Element    ${TOKEN_DROPDOWN}
    Wait Until Element Is Visible    ${FIRST_TOKEN_OPTION}
    Click Element    ${FIRST_TOKEN_OPTION}
    
    # Enter recipient address and amount
    Wait Until Element Is Visible    ${RECIPIENT_ADDRESS_FIELD}
    Input Text    ${RECIPIENT_ADDRESS_FIELD}    ${RECIPIENT_ADDRESS}
    
    Wait Until Element Is Visible    ${AMOUNT_FIELD}
    Input Text    ${AMOUNT_FIELD}    ${TRANSFER_AMOUNT}

Initiate Transfer
    Wait Until Element Is Enabled    ${SEND_BUTTON}
    Click Element    ${SEND_BUTTON}
    
    # Handle approval popup
    Handle Approval Popup
    
    # Verify success
    Wait Until Element Is Visible    ${SUCCESS_TOAST}    timeout=30s
    ${success_message}=    Get Text    ${SUCCESS_TOAST}
    Log    Transaction Success: ${success_message}

Handle Approval Popup
    # Wait for a new window to appear
    ${current_window}=    Get Window Handles
    ${window_count}=    Get Length    ${current_window}
    
    # If new window appears
    Run Keyword If    ${window_count} > 1    Switch To Approval Window
    
Switch To Approval Window
    ${window_handles}=    Get Window Handles
    Switch Window    ${window_handles}[1]
    
    # Approve the transaction
    Wait Until Element Is Visible    ${APPROVE_BUTTON}    timeout=20s
    Click Element    ${APPROVE_BUTTON}
    
    # Wait for popup to close and switch back to main window
    ${window_handles}=    Get Window Handles
    Switch Window    ${window_handles}[0]