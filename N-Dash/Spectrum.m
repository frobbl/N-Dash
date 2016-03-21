//
//  Spectrum.m
//  N-Dash
//
//  Created by John Schilling on 3/12/16.
//  Copyright © 2016 StimSoft LLC. All rights reserved.
//

#import "Spectrum.h"

@interface Spectrum ()
{
    
    
}
- (UIColor *)uiColorWithRed:(float)red green:(float)green blue:(float)blue;
- (UIColor *)uiColorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

@end

@implementation Spectrum

- (id)init
{
    self = [super init];
    if (self)
    {
        self.RedLight       = [self uiColorWithRed:255 green:153 blue:153];
        self.RedMedium      = [self uiColorWithRed:255 green:0 blue:0];
        self.RedDark        = [self uiColorWithRed:153 green:0 blue:0];
        self.Crimson        = [self uiColorWithRed:220 green:20 blue:60];
        self.Tomato         = [self uiColorWithRed:255 green:99 blue:71]; //255,99,71
        self.FooRed         = [self uiColorWithRed:205 green:92 blue:92]; //205,92,92
        self.Coral          = [self uiColorWithRed:255 green:127 blue:80]; //255,127,80
        
        self.BloodOrange    = [self uiColorWithRed:255 green:69 blue:0];//255,69,0

        self.OrangeLight    = [self uiColorWithRed:255 green:178 blue:102];
        self.OrangeMedium   = [self uiColorWithRed:255 green:128 blue:0];
        self.OrangeDark     = [self uiColorWithRed:204 green:102 blue:0];
        
        self.Gold           = [self uiColorWithRed:255 green:215 blue:0];
        self.GoldenRod      = [self uiColorWithRed:218 green:165 blue:32];
        
        self.YellowLight    = [self uiColorWithRed:255 green:255 blue:153];
        self.YellowMedium   = [self uiColorWithRed:255 green:255 blue:51];
        self.YellowDark     = [self uiColorWithRed:204 green:204 blue:0];
        self.YellowGreen    = [self uiColorWithRed:154 green:205 blue:50];
        
        self.GreenLight     = [self uiColorWithRed:153 green:255 blue:153];
        self.GreenMedium    = [self uiColorWithRed:128 green:255 blue:0];
        self.GreenDark      = [self uiColorWithRed:76 green:153 blue:0];
        self.GreenSea       = [self uiColorWithRed:143 green:188 blue:143]; //(143,188,143)
        self.PaleGreen      = [self uiColorWithRed:152 green:251 blue:152];
        self.OliveGreen     = [self uiColorWithRed:128 green:128 blue:0];
        self.OliveDrab      = [self uiColorWithRed:107 green:142 blue:35];
        self.LimeGreen      = [self uiColorWithRed:50 green:205 blue:50];
        self.SpringGreen    = [self uiColorWithRed:0 green:250 blue:154];
        self.LEDGreen       = [self uiColorWithRed:154 green:205 blue:50];
        //154,205,50

        self.BlueLight      = [self uiColorWithRed:0 green:128 blue:255];
        self.BlueMedium     = [self uiColorWithRed:51 green:51 blue:255];
        self.BlueDark       = [self uiColorWithRed:0 green:0 blue:204];
        self.BlueRoyal      = [self uiColorWithRed:65 green:105 blue:225];
        self.Indigo         = [self uiColorWithRed:75 green:0 blue:130];
        self.AquaMarine     = [self uiColorWithRed:127 green:255 blue:212];
        self.Turquoise      = [self uiColorWithRed:64 green:224 blue:208];
        self.CadetBlue      = [self uiColorWithRed:95 green:158 blue:160]; //95,158,160
        self.PowderBlue     = [self uiColorWithRed:176 green:224 blue:230]; //176,224,230
        self.Cyan           = [self uiColorWithRed:0 green:255 blue:255];
        
        self.PurpleLight    = [self uiColorWithRed:204 green:153 blue:255];
        self.PurpleMedium   = [self uiColorWithRed:153 green:51 blue:255];
        self.PurpleDark     = [self uiColorWithRed:102 green:0 blue:204];
        self.Lavender       = [self uiColorWithRed:230 green:230 blue:250];
        
        self.VioletLight    = [self uiColorWithRed:255 green:102 blue:255];
        self.VioletMedium   = [self uiColorWithRed:204 green:0 blue:204];
        self.VioletDark     = [self uiColorWithRed:153 green:0 blue:153];
        
        self.BrownLight     = [self uiColorWithRed:222 green:184 blue:135];
        self.BrownMedium    = [self uiColorWithRed:205 green:133 blue:63];
        self.BrownDark      = [self uiColorWithRed:139 green:69 blue:19];
        self.DarkKhaki      = [self uiColorWithRed:189 green:183 blue:107];
        self.Khaki          = [self uiColorWithRed:240 green:230 blue:140];
        self.Chocolate      = [self uiColorWithRed:210 green:105 blue:30]; //210,105,30

        self.PinkLight      = [self uiColorWithRed:255 green:182 blue:193];
        self.PinkMedium     = [self uiColorWithRed:255 green:105 blue:180];
        self.PinkDark       = [self uiColorWithRed:199 green:21 blue:133];
        self.Salmon         = [self uiColorWithRed:250 green:128 blue:114];
        
        self.GrayLight      = [self uiColorWithRed:220 green:220 blue:220];
        self.GrayMedium     = [self uiColorWithRed:169 green:169 blue:169];
        self.GrayDark       = [self uiColorWithRed:90 green:90 blue:90];
        self.GrayBlack      = [self uiColorWithRed:10 green:10 blue:10];
        
        self.White          = [self uiColorWithRed:255 green:255 blue:255];
        self.Black          = [self uiColorWithRed:0 green:0 blue:0];
        self.Highway        = [self uiColorWithRed:240 green:255 blue:240]; // very light green

        self.Smoke          = [self uiColorWithRed:245 green:245 blue:245];
        self.Ivory          = [self uiColorWithRed:255 green:255 blue:240];
        self.Beige          = [self uiColorWithRed:245 green:245 blue:220];
        self.Flesh          = [self uiColorWithRed:255 green:222 blue:173];
        self.SlateGray      = [self uiColorWithRed:119 green:136 blue:153];
        self.Silver         = [self uiColorWithRed:192 green:192 blue:192];
        
    }
    return self;
}



- (UIColor *)uiColorWithRed:(float)red green:(float)green blue:(float)blue
{
    return [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:1];
}

- (UIColor *)uiColorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    return [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:alpha/255.0f];
}














@end
