*** Settings ***
Library    SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Library    String
Library    Collections
Library    DateTime

*** Variables ***
${BROWSER}    chrome
${URL}        https://mycloudwallet.com
${HOST}        https://mycloudwallet.com
# ${HOST}        https://stg-wallet-ui.waxstg.net
# ${EMAIL}       newstg20221117.1@mailnesia.com
# ${PASSWORD}    W@x123456
${EMAIL}       khainq.timebit@gmail.com
${PASSWORD}    qwertyuiO.2
${2fa}  123123
${user_data_dir}   --user-data-dir=/Users/nk/Library/Application Support/Google/Chrome/User Data
${profile_dir}     --profile-directory=Profile 7
${TURNSTILE_IFRAME}  iframe[name^='cf-chl-widget'], iframe[src*='challenges.cloudflare.com']
${TURNSTILE_CHECKBOX}  css:.ctp-checkbox-label, xpath://div[contains(@class,'checkbox')]

*** Test Cases ***
Open a webpage
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
    
    Register Keyword To Run On Failure    NONE
    
    Go To    ${URL}

Login
    Wait Until Element Is Visible  xpath=//button[span[text()='Login']]
    Click Element    xpath=//button[span[text()='Login']]
    
    Wait Until Element Is Visible  name=email
    Input Text    name=email    ${EMAIL}
    Sleep    3s
    
    Input Text    name=password    ${PASSWORD}
    Sleep    4s
    
    Click Element    xpath=//button[span[text()='Sign In']]
    Sleep    5s
    
    ${turnstile_present}=    Run Keyword And Return Status    Page Should Contain Element    ${TURNSTILE_IFRAME}
    Run Keyword If    ${turnstile_present}    Handle Turnstile Challenge
    
    Wait Until Element Is Visible    id=tfacode    timeout=10s
    Input Text    id=tfacode  ${2fa}
    Click Element    xpath=//button[span[text()='CONTINUE']]
    Sleep    4s

Go to dashboard
    Go To    ${HOST}/dashboard
    Sleep    5s
    
    Click Element    xpath=//div[@class='menu-div-1' and text()='Dashboard']
    Sleep    5s
    
    Click Element    xpath=//div[@class='menu-div-1' and text()='NFTs']
    Sleep    5s
    
    Click Element    xpath=//div[@class='menu-div-1' and text()='Buy & Sell']
    Sleep    5s
    
    Click Element    xpath=//div[@class='menu-div-1' and text()='Explorer']
    Sleep    5s
    
    Click Element    xpath=//div[@class='menu-div-1' and text()='Settings']
    Sleep    5s
    
    Click Element    xpath=//div[@class='menu-div-1' and text()='Dashboard']
    Sleep    5s

Receive
    Click Element    xpath=//button[span[text()='Receive']]
    Sleep    5s
    
    Click Element    xpath=//button[span[text()='Done']]

Send to khainguyen12
    Sleep    5s
    
    Click Element    xpath=//button[span[text()='Send']]
    Sleep    5s
    
    Click Element    xpath=(//div[@class='sc-1ihdvkz-1 dMmGgm select-asset-wrapper'])[0]
    Sleep    5s
    
    Click Element    xpath=(//div[@class='sc-1ihdvkz-1 dMmGgm select-asset'])[2]
    Sleep    5s
    
    Input Text    xpath=//input[@value='0']    0.01
    
    Input Text    xpath=(//input[@type='text'])[1]    khainguyen12
    
    Input Text    xpath=//div[7]//input[1]    automated
    
    Click Element    xpath=//div[@class='send-wax-div-9']//button[@type='button']
    Sleep    5s
    
    Click Element    xpath=//div[@class='transacion-success-div-6']//button[@type='button']
    Sleep    5s

Back to Dashboard
    Go To    ${HOST}/dashboard
    Sleep    5s

Go to NFTs
    Click Element    xpath=//div[@class='tab-token-div-2' and text()='NFTs']
    Sleep    5s

Go to Activity
    Click Element    xpath=//div[@class='tab-token-div-2' and text()='Activity']
    Sleep    5s

Go to Activity > next page
    Click Element    xpath=//div[@class='MuiSvgIcon-root']
    Sleep    5s

Go to Tokens
    Click Element    xpath=//div[@class='tab-token-div-2' and text()='Tokens']
    Sleep    5s
Logout
    Go To    ${HOST}/logout
    Sleep    10s

Close BROWSER
    Close All Browsers

*** Keywords ***
Handle Turnstile Challenge
    Wait Until Element Is Visible    ${TURNSTILE_IFRAME}    timeout=10s
    
    Select Frame    ${TURNSTILE_IFRAME}
    
    Wait Until Element Is Visible    ${TURNSTILE_CHECKBOX}    timeout=10s
    Click Element    ${TURNSTILE_CHECKBOX}
    
    ${puzzle_visible}=    Run Keyword And Return Status    
    ...    Element Should Be Visible    css:.puzzle-container    timeout=3s
    
    Run Keyword If    ${puzzle_visible}    Solve Turnstile Puzzle
    
    Wait Until Element Is Visible    css:.success-indicator    timeout=30s
    
    Unselect Frame
    
    Sleep    5s

Solve Turnstile Puzzle
    Sleep    15s
