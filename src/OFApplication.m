/*
 * Copyright (c) 2008 - 2010
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#include "config.h"

#include <stdlib.h>

#import "OFApplication.h"
#import "OFString.h"
#import "OFArray.h"
#import "OFDictionary.h"
#import "OFAutoreleasePool.h"
#import "OFExceptions.h"

#include <string.h>

#ifdef __MACH__
# include <crt_externs.h>
#else
 extern char **environ;
#endif

static OFApplication *app = nil;

static void
atexit_handler()
{
	id delegate = [app delegate];

	[delegate applicationWillTerminate];
}

int
of_application_main(int argc, char *argv[], Class cls)
{
	OFApplication *app;
	OFObject <OFApplicationDelegate> *delegate = nil;

	if (cls != Nil)
		delegate = [[cls alloc] init];

	app = [OFApplication sharedApplication];

	[app setArgumentCount: argc
	    andArgumentValues: argv];

	[app setDelegate: delegate];
	[delegate release];

	[app run];

	return 0;
}

@implementation OFApplication
+ sharedApplication
{
	if (app == nil)
		app = [[self alloc] init];

	return app;
}

+ (OFString*)programName
{
	return [app programName];
}

+ (OFArray*)arguments
{
	return [app arguments];
}

+ (OFDictionary*)environment
{
	return [app environment];
}

+ (void)terminate
{
	exit(0);
}

+ (void)terminateWithStatus: (int)status
{
	exit(status);
}

- init
{
	OFAutoreleasePool *pool;
	char **env;

	self = [super init];

	environment = [[OFMutableDictionary alloc] init];

	atexit(atexit_handler);
#ifdef __MACH__
	env = *_NSGetEnviron();
#else
	env = environ;
#endif

	pool = [[OFAutoreleasePool alloc] init];
	for (; *env != NULL; env++) {
		OFString *key;
		OFString *value;
		char *sep;

		if ((sep = strchr(*env, '=')) == NULL) {
			fprintf(stderr, "Warning: Invalid environment "
			    "variable: %s\n", *env);
			continue;
		}

		key = [OFString stringWithCString: *env
					   length: sep - *env];
		value = [OFString stringWithCString: sep + 1];
		[environment setObject: value
				forKey: key];

		[pool releaseObjects];
	}
	[pool release];

	return self;
}

- (void)setArgumentCount: (int)argc
       andArgumentValues: (char**)argv
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	int i;

	[programName release];
	[arguments release];

	programName = [[OFString alloc] initWithCString: argv[0]];
	arguments = [[OFMutableArray alloc] init];

	for (i = 1; i < argc; i++)
		[arguments addObject: [OFString stringWithCString: argv[i]]];

	[pool release];
}

- (OFString*)programName
{
	return [[programName retain] autorelease];
}

- (OFArray*)arguments
{
	return [[arguments retain] autorelease];
}

- (OFDictionary*)environment
{
	return [[environment retain] autorelease];
}

- (OFObject <OFApplicationDelegate>*)delegate
{
	return [[delegate retain] autorelease];
}

- (void)setDelegate: (OFObject <OFApplicationDelegate>*)delegate_
{
	id old = delegate;
	delegate = [delegate_ retain];
	[old release];
}

- (void)run
{
	[delegate applicationDidFinishLaunching];
}

- (void)terminate
{
	exit(0);
}

- (void)terminateWithStatus: (int)status
{
	exit(status);
}

- (void)dealloc
{
	[arguments release];
	[environment release];
	[delegate release];

	[super dealloc];
}
@end

@implementation OFObject (OFApplicationDelegate)
- (void)applicationDidFinishLaunching
{
	@throw [OFNotImplementedException newWithClass: isa
					      selector: _cmd];
}

- (void)applicationWillTerminate
{
}
@end
