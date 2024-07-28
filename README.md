# 1inch Swap Project

## Overview

This project is a Flutter application that allows users to perform token swaps using the 1inch API and Binance Smart Chain. It uses BLoC for state management and demonstrates how to interact with smart contracts and external APIs in a Flutter app.

## Features

- Fetch and display token information
- Perform token swaps
- Check and manage token allowances
- Handle transaction approvals

## Setup Instructions

Follow these steps to set up and run the project locally.

### Prerequisites

- Flutter SDK (used 3.22.2)
- Dart SDK
- An API key from 1inch
- A private key for Ethereum transactions

### Clone the Repository


git clone https://github.com/sharma0017/1inch-swap.git
cd 1inch-swap
Install Dependencies
Ensure you have Flutter installed on your machine. Then run:

flutter pub get

### Configure Environment Variables

Rename the .env.example file to .env:


mv .env.example .env


### Edit .env File

Open the .env file in your preferred text editor and add your API key and private key. It should look like this:

env
Copy code
PRIVATE_KEY=your_private_key_here
API_KEY=your_api_key_here
Replace your_private_key_here with your Ethereum private key and your_api_key_here with your 1inch API key.

### Run the Application
Make sure an emulator or device is running. Then use the following command to start the application:

flutter run
