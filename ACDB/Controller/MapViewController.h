
//
//  MapViewController.m
//  ACDB
//
//  Created by Rommel on 17/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"
#import "CustomPlacemark.h"
#import "Definitions.h"

@interface MapViewController : UIViewController<MKMapViewDelegate,UISearchBarDelegate,BSForwardGeocoderDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) BSForwardGeocoder *forwardGeocoder;
@property (nonatomic,strong) NSString* addressString;

@end
