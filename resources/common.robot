*** Settings ***
Library    SeleniumLibrary    screenshot_root_directory=None    run_on_failure=None
Library    DateTime
Library    Process
Library    OperatingSystem
Library    Collections
Resource    variables.robot


*** Variables ***
${BROWSER}              chrome
${TIMEOUT}              20s
${SELENIUM_TIMEOUT}     20s
${SELENIUM_SPEED}       0.5s

*** Keywords ***
Open Browser To URL
    [Arguments]    ${url}    ${use_profile}=False
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    # Apply common options
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --no-sandbox
    # Apply profile-specific options if requested
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_argument    ${USER_DATA_DIR}
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_argument    ${PROFILE_DIR}
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_argument    --disable-blink-features=AutomationControlled
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_argument    --disable-infobars
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_argument    --disable-browser-side-navigation
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_argument    --disable-gpu
    ${exclude_switches}=    Create List    enable-automation
    Run Keyword If    ${use_profile}    Call Method    ${options}    add_experimental_option    useAutomationExtension    ${False}
    Open Browser    ${url}    chrome    options=${options}    executable_path=/usr/local/bin/chromedriver
    Maximize Browser Window
    Set Selenium Implicit Wait    ${PAGE_LOAD_TIME}
Open New Tab To URL
    [Arguments]    ${url}
    Execute Javascript    window.open('${url}');

Switch To Tab
    [Arguments]    ${tab_index}
    ${handles}=    Get Window Handles
    Switch Window    ${handles}[${tab_index}]

Handle Captcha
    [Documentation]    Tick the captcha checkbox (used in sign-up)
    Click Element    ${CAPTCHA_CHECKBOX}
Open Browser With Options
    [Arguments]    ${url}    ${browser}=chrome
    
    # Import required libraries dynamically
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    
    # Basic Chrome options
    @{chrome_args}=    Create List
    ...    --disable-blink-features=AutomationControlled
    ...    --start-maximized
    ...    --no-sandbox
    ...    --disable-dev-shm-usage
    
    # Add arguments dynamically
    FOR    ${arg}    IN    @{chrome_args}
        Call Method    ${chrome_options}    add_argument    ${arg}
    END
    
    # Configure experimental options
    ${exclude_switches}=    Create List    enable-automation
    Call Method    ${chrome_options}    add_experimental_option    excludeSwitches    ${exclude_switches}
    Call Method    ${chrome_options}    add_experimental_option    useAutomationExtension    ${FALSE}
    
    # Error handling for WebDriver creation
    Run Keyword And Ignore Error    Close All Browsers
    
    # Open browser with configuration
    Create Webdriver    Chrome    options=${chrome_options}
    
    # Navigation and setup
    Go To    ${url}
    Maximize Browser Window
    
    # Set timeouts and speed
    Set Selenium Timeout    ${SELENIUM_TIMEOUT}
    Set Selenium Speed    ${SELENIUM_SPEED}
    
    # Implicit wait for better element interaction
    Set Selenium Implicit Wait    10s

Close All Browsers Gracefully
    [Documentation]    Safely close all browser instances
    Run Keyword And Ignore Error    Close All Browsers
    Run Keyword And Ignore Error    Terminate All Processes

Capture Diagnostic Information
    [Documentation]    Capture additional diagnostic info on test failure
    Run Keyword If Test Failed    Run Keywords
    ...    Capture Page Screenshot    
    ...    Log Source
    ...    Log Title