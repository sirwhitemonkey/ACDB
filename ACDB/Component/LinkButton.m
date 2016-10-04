#import "LinkButton.h"

@implementation LinkButton
@synthesize managedObject;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
    }
    return self;
}
- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
    
    /*
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
  
    */
    
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = 1.0f;
    self.titleLabel.textColor= [UIColor blackColor];
    
    //make the buttons content appear in the top-left
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    
    //move text 10 pixels down and right
    //[self setTitleEdgeInsets:UIEdgeInsetsMake(3.5f, 8.0f, 0.0f, 0.0f)];
}



@end
