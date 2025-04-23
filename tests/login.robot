*** Settings ***
Library    SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Library    OperatingSystem

*** Variables ***
${BROWSER}    chrome
${URL}    https://mycloudwallet.com
${EMAIL}    khainq.timebit@gmail.com
${PASSWORD}    qwertyuiO.1
${login}    //span[text()='Login']
${email_input}    name=email
${password_input}    name=password
${sign_in_button}    //span[text()='Sign In']
${user_data_dir}   --user-data-dir=/Users/nk/Library/Application Support/Google/Chrome/User Data
${profile_dir}     --profile-directory=Profile 7
${chrome_options}    add_argument("--disable-blink-features=AutomationControlled");add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--disable-infobars");add_argument("--disable-browser-side-navigation");add_argument("--disable-gpu");add_experimental_option("excludeSwitches", ["enable-automation"]);add_experimental_option("useAutomationExtension", False)

*** Test Cases ***
Go to Login Page
    # Open Browser    ${URL}    browser=${BROWSER}    options=${chrome_options}
    ${options}=    Evaluate    selenium.webdriver.ChromeOptions()    selenium.webdriver
    
    @{chrome_arguments}=    Create List
    ...    ${user_data_dir}
    ...    ${profile_dir}
    ...    disable-blink-features=AutomationControlled
    ...    disable-infobars
    ...    window-size=1920,1080
    ...    disable-dev-shm-usage
    ...    no-sandbox
    ...    disable-gpu
    
    FOR    ${argument}    IN    @{chrome_arguments}
        Call Method    ${options}    add_argument    ${argument}
    END
    
    ${prefs}=    Create Dictionary    
    ...    credentials_enable_service=${FALSE}    
    ...    profile.password_manager_enabled=${FALSE}
    ...    profile.default_content_setting_values.media_stream_camera=2
    ...    profile.default_content_setting_values.media_stream_mic=2
    ...    profile.default_content_setting_values.notifications=2
    ...    profile.default_content_setting_values.geolocation=2
    ...    profile.default_content_setting_values.images=2
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    
    ${exclude_switches}=    Create List    enable-automation    enable-logging
    Call Method    ${options}    add_experimental_option    excludeSwitches    ${exclude_switches}
    
    Create WebDriver    Chrome    options=${options}

    Maximize Browser Window
    Execute JavaScript    Object.defineProperty(navigator, 'webdriver', {get: () => undefined})
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
    [Teardown]    Close Browser 

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