//
//  Definitions.h
//  ACDB
//
//  Created by Rommel on 11/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//



typedef  enum{
    PageAccounts=0,
    PageContacts=1,
    PageDiscussions=2,
    PageBringUps=3,
    PageCountry=4,
    PageRelationship=5,
    PageStdInClass=6,
    PageSupportLevel=7,
    PageContactType=8,
    PageBuyingPower=9,
    PageAccountNames=10,
    PageAccUserDef1=11,
    PageAccUserDef2=12,
    PageAccUserDef3=13,
    PageAccUserDef4=14,
    PageConUserDef1=15,
    PageConUserDef2=16,
    PageConUserDef3=17,
    PageConUserDef4=18
}PageController;


typedef  enum{
    ManagedContextFile_Upload = 0,
    ManagedContextFile_Download = 1,
    ManagedContextFile_Backup = 2
}ManagedContextFile;


typedef  enum{
    ManagedObjectContextType_Local = 0,
    ManagedObjectContextType_DropBox = 1,
    ManagedObjectContextType_Cache = 2
}ManagedObjectContextType;

typedef enum {
    PageRequest_Account_Accounts=0,
    PageRequest_Account_AccountNames=1,
    PageRequest_Account_Relationship=2,
    PageRequest_Account_StdInClass=3,
    PageRequest_Account_PrimaryContact=4,
    PageRequest_Account_SecondaryContact=5,
    PageRequest_Account_BillingContact=6,
    PageRequest_Account_AccountsContact=7,
    PageRequest_Account_MailingCountry=8,
    PageRequest_Account_PostalCountry=9,
    PageRequest_Account_MailingMap=10,
    PageRequest_Account_PostalMap=11,
    PageRequest_Account_AllContacts=12,
    PageRequest_Account_Discussions=13,
    PageRequest_Account_NewDiscussion=14,
    PageRequest_Account_AccUserDef1=15,
    PageRequest_Account_AccUserDef2=16,
    PageRequest_Account_AccUserDef3=17,
    PageRequest_Account_AccUserDef4=18,
    PageRequest_Contact_Birthday = 19,
    PageRequest_Contact_BuyingPower=20,
    PageRequest_Contact_SupportLevel=21,
    PageRequest_Contact_ConUserDef1=22,
    PageRequest_Contact_ConUserDef2=23,
    PageRequest_Contact_ConUserDef3=24,
    PageRequest_Contact_ConUserDef4=25,
    PageRequest_Discussion_ContactDate=26,
    PageRequest_Discussion_BringupDate=27,
    PageRequest_Discussion_ContactPerson=28,
    PageRequest_Discussion_ContactType=29,
    PageRequest_Bringups_Discussions=30
    
}PageRequest;

typedef  enum{
    ManagedSections_Data = 0,
    ManagedSections_AddEdit = 1,
    ManagedSections_Sections = 2,
    ManagedSections_Edit  = 100,
    ManagedSections_Done = 200,
    ManagedSections_Camera = 300,
    ManagedSections_StreetView = 400
}ManagedSections;


#define GROUP_FILTERED @"GROUP_FILTERED"
#define GROUP_NORMAL @"GROUP_NORMAL"

#define ENTITY_DISCUSSION @"Discussion"
#define ENTITY_COUNTRY @"Country"
#define ENTITY_BUYINGPOWER @"BuyingPower"
#define ENTITY_SUPPORTLEVEL @"SupportLevel"
#define ENTITY_CONTACTTYPE @"ContactType"
#define ENTITY_CONTACT @"Contact"
#define ENTITY_STDINCLASS @"StdInClass"
#define ENTITY_ACCOUNT @"Account"
#define ENTITY_RELATIONSHIP @"Relationship"
#define ENTITY_ACCOUNTNAMES @"AccountNames"
#define ENTITY_ACCUSERDEF @"AccUserDef"
#define ENTITY_CONUSERDEF @"ConUserDef"
#define ENTITY_SOFTLABELS @"SoftLabels"
#define ENTITY_METAFILE @"MetaFile"

#define SAMPLE_ACCOUNTNAMES_DATA [NSArray  arrayWithObjects:@"Legal Name",@"Project Name",@"Job Name",nil]
#define SAMPLE_ACCUSERDEF1_DATA [NSArray  arrayWithObjects:@"AccUserDef1",nil]
#define SAMPLE_ACCUSERDEF2_DATA [NSArray  arrayWithObjects:@"AccUserDef2",nil]
#define SAMPLE_ACCUSERDEF3_DATA [NSArray  arrayWithObjects:@"AccUserDef3",nil]
#define SAMPLE_ACCUSERDEF4_DATA [NSArray  arrayWithObjects:@"AccUserDef4",nil]
#define SAMPLE_CONUSERDEF1_DATA [NSArray  arrayWithObjects:@"ConUserDef1",nil]
#define SAMPLE_CONUSERDEF2_DATA [NSArray  arrayWithObjects:@"ConUserDef2",nil]
#define SAMPLE_CONUSERDEF3_DATA [NSArray  arrayWithObjects:@"ConUserDef3",nil]
#define SAMPLE_CONUSERDEF4_DATA [NSArray  arrayWithObjects:@"ConUserDef4",nil]


#define SAMPLE_RELATIONSHIP_DATA [NSArray  arrayWithObjects:@"Customer",@"Prospect",@"Lost/Recoverable",@"Not Worth Pursuit",@"Partner",@"Supplier",nil]
#define SAMPLE_STDINCLASS_DATA [NSArray  arrayWithObjects:@"Manufacturing",@"Accounting",@"ICT",@"Legal",@"Transport",nil]
#define SAMPLE_BUYINGPOWER_DATA [NSArray  arrayWithObjects:@"DecisionMaker",@"Influencer",@"ReceiverOfInfo",@"NoBuyingPower",nil]
#define SAMPLE_SUPPORTLEVEL_DATA [NSArray  arrayWithObjects:@"Advocate",@"Supporter",@"Neutral",@"Negative",@"Enemy",nil]
#define SAMPLE_CONTACTTYPE_DATA [NSArray  arrayWithObjects:@"We emailed/wrote",@"We phoned them",@"We visited them",@"We (other contact)",@"They emailed/wrote",@"They phoned us",@"They visited us",@"They (other contact)",@"A note to myself",nil]
#define SAMPLE_COUNTRY_DATA [NSArray  arrayWithObjects:@"New Zealand",@"Australia",@"United States",@"United Kingdom",nil]

#define WARNING_TOOLTIPS_BACKGROUND [UIColor colorWithRed:220.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define NORMAL_TOOLTIPS_BACKGROUND [UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0f]

#define textViewFont [UIFont systemFontOfSize:14.0f]

#define ACDB_DB @"ACDB.db"

#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define COLOR_C5C6C2 [UIColor colorWithRed:197.0/255.0 green:198.0/255.0 blue:194.0/255.0 alpha:1.0]

#define DEVICE_NOT_SUPPORT_FEATURE @"Device does not support this feature"
#define EVENT_CREATED @"Event Created"
#define ERROR_BRINGUPDATE @"Bringup Date cannot be prior to Contact Date"
#define ERROR_CONTACTDATE @"Contact Date cannot be prior to Bringup Date"
#define EMAIL_SENT @"Email successfully sent"
#define INVALID_EMAIL_ADDRESS @"Invalid email address"
#define INVALID_URL @"Invalid website"
#define SOURCE_REMOVED @"_SOURCE_ had already been removed"
#define SOURCE_REQUIRED @"_SOURCE_ is required"
#define SOURCE_NOT_AVAILABLE @"_SOURCE_ is not available"

#define HELPTEXT 999
#define BRINGUPS 998

#define ACCOUNTS_HELPTEXT @"accounts"
#define CONTACTS_HELPTEXT @"contacts"
#define DISCUSSIONS_HELPTEXT @"discussions"
#define BRINGUPS_HELPTEXT @"bringups"

#define DROPBOX_APP_KEY @"acdb_dropbox_app_key"
#define DROPBOX_APP_SECRET @"acdb_dropbox_app_secret"

// Allan's Dropbox
#define DROPBOX_APP_KEY_VALUE @"uowz4pa8vo2jcbr"
#define DROPBOX_APP_KEY_SECRET_VALUE @"a0dssbry05hgfeu"

//My tests Dropbox
//#define DROPBOX_APP_KEY_VALUE @"7sxjdvc3gfl87k1"
//#define DROPBOX_APP_KEY_SECRET_VALUE @"z9fvwbfqzvae6gx"
//#define DROPBOX_APP_KEY_VALUE @"8z1vqf0pnmncn6o"
//#define DROPBOX_APP_KEY_SECRET_VALUE @"rqg4slafafg6iyz"

#define GOOGLE_MAPS_API_KEY_VALUE @"AIzaSyBxpxHbtuuFhrrjmh-D5aeRA0N2VS6WqEw"

#define MAX_TEXT_FIELDS 100
