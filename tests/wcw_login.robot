*** Settings ***
Documentation    Test automation for MyCloudWallet token transfer
Resource         ../resources/common.robot
Library    SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Library    OperatingSystem

*** Variables ***
${URL}    https://mycloudwallet.com
${EMAIL}    khainq.timebit@gmail.com
${PASSWORD}    qwertyuiO.1
${login}    //span[text()='Login']
${email_input}    name=email
${password_input}    name=password
${sign_in_button}    //span[text()='Sign In']

*** Test Cases ***
# Transfer Token Test
#     [Documentation]    Login to MyCloudWallet and transfer token to another wallet
    
#     # Step 1: Login to the wallet
#     Login To MyCloudWallet
    
#     # Step 2: Navigate to transfer page
#     Navigate To Transfer Page
    
#     # Step 3: Select token and enter transfer details
#     Select Token And Enter Transfer Details
    
#     # Step 4: Initiate transfer and approve
#     Initiate Transfer
    
#     # Verify success message is displayed
#     Page Should Contain Element    ${SUCCESS_TOAST}

Go to Login Page
    Open Browser With Options    ${URL}
    Wait Until Element Is Visible    ${login}    timeout=10s
    Click Element    ${login}
    Sleep    2s

Login To MyCloudWallet
    # Add random delay to simulate human behavior
    Set Random Delay
    Sleep    ${RANDOM_DELAY}s
    Wait Until Element Is Visible    ${email_input}    timeout=10s
    # Type with random delays between keystrokes
    Input Text   ${email_input}    ${EMAIL}
    Sleep    1s
    Input Text   ${password_input}    ${PASSWORD}
    Sleep    ${RANDOM_DELAY}s
    Click Element    ${sign_in_button}
    Handle Captcha
    Sleep    20s
    [Teardown]    Close All Browsers Gracefully

*** Keywords ***
Get Random Delay
    ${random}=    Evaluate    random.uniform(0.5, 2.0)    random
    [Return]    ${random}

Input Text With Delay
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}
    Click Element    ${locator}
    FOR    ${char}    IN    @{text}
        Press Key    ${locator}    ${char}
        ${delay}=    Get Random Delay
        Sleep    ${delay}
    END

Set Random Delay
    ${RANDOM_DELAY}=    Evaluate    random.uniform(1.0, 3.0)    random
    Set Test Variable    ${RANDOM_DELAY}
    
Handle Captcha
    # Add captcha handling logic here if needed
    # This is a placeholder for actual captcha bypass logic
    ${captcha_present}=    Run Keyword And Return Status    Element Should Be Visible    id=captcha
    Run Keyword If    ${captcha_present}    Log    Captcha detected, implementing bypass...