# MyCloudWallet Robot Framework Tests

This project contains automated tests for mycloudwallet.com using Robot Framework.

## Prerequisites

- Python 3.8 or higher
- Chrome browser installed
- ChromeDriver (will be automatically managed by webdrivermanager)

## Setup

1. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running Tests

To run the login test:
```bash
robot tests/login.robot
```

## Project Structure

- `tests/` - Contains all test files
- `requirements.txt` - Project dependencies
- `README.md` - This file

## Test Cases

Currently implemented:
- Login functionality test 