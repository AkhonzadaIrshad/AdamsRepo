# MFSDKiOS

# Introduction
Those building new integrations should consider using  MyFatoorah, which is the easiest way to accept Knet, credit cards, and many other MyFatoorah payment methods.

The MFSDK makes it easy to add MyFatoorah payments to mobile apps.

# Prerequisites
You will need a [My Fatoorah](https://myfatoorah.com) account.

# Installation
1. You can download MFSDK using Cocoapod, just add this line to your Podfile

- For Swift 5.0
```
pod 'MyFatoorah', '1.1.14'
```

- For Objective - C
```
pod 'MyFatoorah', '1.1.14'
```

Then in your terminal :
- first run this command to get latest pod:
```
pod repo update
```
- then run  install command:
```
pod install
```

# Usage

1. Import framework in AppDelegate
```
import MFSDK
```

2. Add below code in didFinishLaunchingWithOptions method


# Swift 
```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
// Override point for customization after application launch.
// set up your My Fatoorah Merchant details
MFSettings.shared.configure(username: "apiaccount@myfatoorah.com", password: "api12345*", baseURL: "https://apidemo.myfatoorah.com/")

// you can change color and title of nvgigation bar
let them = MFTheme(navigationTintColor: .white, navigationBarTintColor: .lightGray, navigationTitle: "Payment", cancelButtonTitle: "Cancel")
MFSettings.shared.setTheme(theme: them)
return true
}
```

# Objective - C
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// set up your My Fatoorah Merchant details
[[MFSettings shared] configureWithUsername:@"apiaccount@myfatoorah.com" password:@"api12345*" baseURL:@"https://apidemo.myfatoorah.com/"];

// you can change color and title of nvgigation bar
MFTheme* theme = [[MFTheme alloc] initWithNavigationTintColor:[UIColor whiteColor] navigationBarTintColor:[UIColor lightGrayColor] navigationTitle:@"Payment" cancelButtonTitle:@"Cancel"];
[[MFSettings shared] setThemeWithTheme:theme];

return YES;
}

```
After finish testing don't forget to replace the demo username and password with your live API user.
if you didn't create one yet, please follow [Create API user](#create-api-user) to create one and use it.  

```
Also don't forget to change the baseURL To live URL

 KW : https://apikw.myfatoorah.com/
 SA : https://apisa.myfatoorah.com/
 BH : https://apibh.myfatoorah.com/
 AE : https://apiae.myfatoorah.com/
 QA : https://apiqa.myfatoorah.com/

```
# Create Invoice 
# Swift 
```
let invoiceValue = 5.0
let invoice = MFInvoice(invoiceValue: invoiceValue, customerName: "Test", countryCode: .kuwait, displayCurrency: .Kuwaiti_Dinar_KWD)
var paymentMethod : MFPaymentMethod =  .all
/*
paymentMethod = .knet
paymentMethod = .mada
paymentMethod = .visaMaster
paymentMethod = .qatarDebitCard
paymentMethod = .benefit
paymentMethod = .debitCardUAE
paymentMethod = .amex
paymentMethod = .sadad
paymentMethod = .mpgs
 */

/* if you choose paymentMethod not allowed for you it will  open .all */

MFPaymentRequest.shared.createInvoice(invoice: invoice, paymentMethod: paymentMethod, apiLanguage: .english)

```

# Objective - C
```
double invoiceValue = 5.0;
MFInvoice* invoice = [[MFInvoice alloc] initWithInvoiceValue:invoiceValue customerName: @"Test" countryCode: MFCountryKuwait displayCurrency:MFCurrencyKuwaiti_Dinar_KWD];
MFPaymentMethod paymentMethod  =  MFPaymentMethodAll;
[[MFPaymentRequest shared] createInvoiceWithInvoice:invoice paymentMethod:paymentMethod apiLanguage:MFAPILanguageArabic];

```


# Direct Payment  

Allows you simply to process the full payment and result within your application or website through our APIs. By passing the needed parameters, we simply take care of executing the transaction and authorize it with the issuer bank through the gateway and return you the result to be displayed within your application. Rest back and relax, all data communicated with MyFatoorah are encrypted!

```
Please note that this feature requires pre-approval for your account with MyFatoorah,
please contact the account manager for more details about this.

```
# Swift 

```
let invoice = MFInvoice(invoiceValue: 5.0, customerName: "Test", countryCode: .kuwait, displayCurrency: .Kuwaiti_Dinar_KWD)

// create your card
let card = MFCard(cardExpiryMonth: "05", cardExpiryYear: "21", cardSecurityCode: "100", cardNumber: "2223000000000007")
// pay!
MFPaymentRequest.shared.createInvoice(invoice: invoice, card: card, apiLanguage: .english)

```

# Objective - C
```
double invoiceValue = 5.0;
MFInvoice* invoice = [[MFInvoice alloc] initWithInvoiceValue:invoiceValue customerName: @"Test" countryCode: MFCountryKuwait displayCurrency:MFCurrencyKuwaiti_Dinar_KWD];


NSString* expiryMM = "05";
NSString* expiryYY = "21";
NSString* cvv = "100";
NSString* cardNumber = "2223000000000007";

MFCard* card = [[MFCard alloc] initWithCardExpiryMonth:expiryMM cardExpiryYear:expiryYY cardSecurityCode:cvv cardNumber:cardNumber];

[[MFPaymentRequest shared] createInvoiceWithInvoice:invoice card:card apiLanguage:MFAPILanguageArabic];

```


### You can use both MFSDKDemo-Swift and  MFSDKDemo-Objective-C to know how use MFSDK.



# Test Cards Details
1. KNET Test Cards
    - 8888880000000001 (any Pin /Expiry) Captured
    - 8888880000000002 (any Pin /Expiry) Not Captured

2. MasterCard Test Cards
    - Card No: 5123456789012346 
    - Expiry Date : 05/17
    - CVV: 123

    - Card No : 5313581000123430
    - Expiry Date : 05/17
    - CVV: 123

3. Visa Test Cards
    - Card No: 4005550000000001 
    - Expiry Date : 05/17
    - CVV: 123

    - Card No : 4557012345678902
    - Expiry Date : 05/17
    - CVV: 123

4. Direct Payment Test Cards
    - Card No: 2223000000000007 
    - Expiry Date: 05/21
    - Security Code: 100
    
## Create API user
Live credentials, You need to create a new api user using below steps:

1- Open MyFatoorah portal

        For KW portal: https://kw.myfatoorah.com

        for SA portal: https://sa.myfatoorah.com

        for BH portal: https://bh.myfatoorah.com

        for AE portal: https://ae.myfatoorah.com

        for QA portal: https://qa.myfatoorah.com

2- Use your Super Master account to sign in (Your vendor Account) .

3- Click on Manage Users on the left menu then select Create User.

4- Insert user details and select API in the Roles section.

5- You will receive an email to reset the password

Once you created the API user and changed the password. Please send us the API user email to enable.



 
