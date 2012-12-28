//
//  main.m
//  blinkcpu
//
//  Created by Chris Reed on 12/18/12.
//  Copyright (c) 2012 Chris Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuMeterCPUStats.h"
#import "hidapi.h"
#import "Blink1.h"
#import <unistd.h>
#import <stdlib.h>

#define LOAD_UPDATE_INTERVAL (0.5)

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        int result = hid_init();
        if (result < 0)
        {
            NSLog(@"Failed to init hid library (%d)", result);
            return 1;
        }
        
        MenuMeterCPUStats * stats = [[MenuMeterCPUStats alloc] init];
        uint32_t cpuCount = [stats numberOfCPUs];
        
        Blink1 * blink = [[Blink1 alloc] init];
        [blink enumerate];
        
        // Loop forever.
        while (true)
        {
            @autoreleasepool
            {
                NSArray * load = [stats currentLoad];

                float combinedTotal = 0.0;
                float combinedSystem = 0.0;
                float combinedUser = 0.0;
                int cpuNum = 0;
                
                for (NSDictionary * loadInfo in load)
                {
                    
                    float system = [[loadInfo objectForKey:@"system"] floatValue];
                    float user = [[loadInfo objectForKey:@"user"] floatValue];
                    float total = system + user;
                    
                    combinedSystem += system;
                    combinedUser += user;
                    combinedTotal += total;
                    
                    ++cpuNum;
                }
                
                combinedSystem /= (float)cpuCount;
                combinedUser /= (float)cpuCount;;
                combinedTotal /= (float)cpuCount;
                
                combinedTotal = MAX(0.07, combinedTotal);
                
                NSColor * loadColor;
                loadColor = [NSColor colorWithCalibratedRed:combinedTotal green:0.0 blue:0.0 alpha:1.0];
                
                [blink fadeToRGB:loadColor atTime:LOAD_UPDATE_INTERVAL];
            }
                
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:LOAD_UPDATE_INTERVAL]];
        }
    }
    
    return 0;
}

