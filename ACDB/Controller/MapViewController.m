//
//  MapViewController.m
//  ACDB
//
//  Created by Rommel on 17/04/14.
//  Copyright (c) 2014 RLBZR. All rights reserved.
//



#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.showsUserLocation=NO;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate=self;
    self.searchBar.delegate=self;
	// Do any additional setup after loading the view.
    
    self.searchBar.text=self.addressString;
    [self searchBarSearchButtonClicked:self.searchBar];
    self.navigationItem.title=@"Map";
    
    if (IS_IOS_7)
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - UI Events
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	NSLog(@"Searching for: %@", self.searchBar.text);
	if (self.forwardGeocoder == nil) {
		self.forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
    // If you want to bias on coordinates pass a bounds object. This example is proof that the "Winnetka" example works (see https://developers.google.com/maps/documentation/geocoding/#Viewports)
    CLLocationCoordinate2D southwest, northeast;
    southwest.latitude = -44.172684;
    southwest.longitude = 164;
    northeast.latitude = -24.236144;
    northeast.longitude = 185;
    BSForwardGeocoderCoordinateBounds *bounds = [BSForwardGeocoderCoordinateBounds boundsWithSouthWest:southwest northEast:northeast];
    
	// Forward geocode!
#if NS_BLOCKS_AVAILABLE
    [self.forwardGeocoder forwardGeocodeWithQuery:self.searchBar.text regionBiasing:nil viewportBiasing:bounds success:^(NSArray *results) {
        [self forwardGeocodingDidSucceed:self.forwardGeocoder withResults:results];
    } failure:^(int status, NSString *errorMessage) {
        if (status == G_GEO_NETWORK_ERROR) {
            [self forwardGeocoderConnectionDidFail:self.forwardGeocoder withErrorMessage:errorMessage];
        }
        else {
            [self forwardGeocodingDidFail:self.forwardGeocoder withErrorCode:status andErrorMessage:errorMessage];
        }
    }];
#else
    [self.forwardGeocoder forwardGeocodeWithQuery:self.searchBar.text regionBiasing:nil viewportBiasing:nil];
#endif
}

#pragma mark - MKMap methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    if ([annotation isKindOfClass:[CustomPlacemark class]]) {
		MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
		newAnnotation.pinColor = MKPinAnnotationColorGreen;
		newAnnotation.animatesDrop = YES;
		newAnnotation.canShowCallout = YES;
		newAnnotation.enabled = YES;
		
		NSLog(@"Created annotation at: %f %f", ((CustomPlacemark*)annotation).coordinate.latitude, ((CustomPlacemark*)annotation).coordinate.longitude);
		
		[newAnnotation addObserver:self
						forKeyPath:@"selected"
						   options:NSKeyValueObservingOptionNew
						   context:@"GMAP_ANNOTATION_SELECTED"];
        
		return newAnnotation;
	}
	
	return nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(NSString *)context{
	
	NSString *action = (NSString*)context;
	
	// We only want to zoom to location when the annotation is actaully selected. This will trigger also for when it's deselected
	if([[change valueForKey:@"new"] intValue] == 1 && [action isEqualToString:@"GMAP_ANNOTATION_SELECTED"])  {
		if ([((MKAnnotationView*) object).annotation isKindOfClass:[CustomPlacemark class]]) {
			//CustomPlacemark *place = ((MKAnnotationView*) object).annotation;
			
			// Zoom into the location
			//[self.mapView setRegion:place.coordinateRegion animated:TRUE];
			NSLog(@"annotation selected: %f %f", ((MKAnnotationView*) object).annotation.coordinate.latitude, ((MKAnnotationView*) object).annotation.coordinate.longitude);
		}
	}
}

#pragma mark - BSForwardGeocoderDelegate methods

- (void)forwardGeocoderConnectionDidFail:(BSForwardGeocoder *)geocoder withErrorMessage:(NSString *)errorMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:errorMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
}


- (void)forwardGeocodingDidSucceed:(BSForwardGeocoder *)geocoder withResults:(NSArray *)results
{
    // Add placemarks for each result
    CustomPlacemark *placemark;
    for (NSUInteger i = 0, resultCount = [results count]; i < resultCount; i++) {
        BSKmlResult *place = [results objectAtIndex:i];
        
        // Add a placemark on the map
        placemark = [[CustomPlacemark alloc] initWithRegion:place.coordinateRegion];
        placemark.title = place.address;
        placemark.subtitle = place.countryName;
        [self.mapView addAnnotation:placemark];
        
    }
    [self performSelector:@selector(openCallout:)
               withObject:placemark
               afterDelay:0.5];
    
    if ([results count] == 1) {
        BSKmlResult *place = [results objectAtIndex:0];
        
        // Zoom into the location
        MKCoordinateRegion region=place.coordinateRegion;
        NSLog(@"%f",region.span.latitudeDelta);
        NSLog(@"%f",region.span.longitudeDelta);
        region.span.latitudeDelta=0.2;
        region.span.longitudeDelta=0.2;
        //[self.mapView setRegion:region animated:YES];
    }
    
    // Dismiss the keyboard
    [self.searchBar resignFirstResponder];
}

- (void)forwardGeocodingDidFail:(BSForwardGeocoder *)geocoder withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage
{
    NSString *message = @"";
    
    switch (errorCode) {
        case G_GEO_BAD_KEY:
            message = @"The API key is invalid.";
            break;
            
        case G_GEO_UNKNOWN_ADDRESS:
            message = [NSString stringWithFormat:@"Could not find %@", @"searchQuery"];
            break;
            
        case G_GEO_TOO_MANY_QUERIES:
            message = @"Too many queries has been made for this API key.";
            break;
            
        case G_GEO_SERVER_ERROR:
            message = @"Server error, please try again.";
            break;
            
            
        default:
            break;
    }
    
    [appDelegate alert:message];
}

#pragma mark center
- (void)openCallout:(id <MKAnnotation>)annotation {
    CLLocationDistance distance = 100;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( annotation.coordinate, distance, distance);
    [self.mapView setRegion:region animated:YES];
    [self.mapView deselectAnnotation:annotation
                            animated:NO];
    [self.mapView selectAnnotation:annotation
                          animated:NO];
}


@end
