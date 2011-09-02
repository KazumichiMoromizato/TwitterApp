//
//  RootViewController.m
//  NavigationBasedAppFirst
//
//  Created by 金城 拓実 on 11/09/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "SBJson.h"
#import "FMDatabase.h"

@implementation RootViewController
@synthesize statuses;


- (void)updateStatuses
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"sample.db"];
    
    statuses = [[NSMutableArray alloc] init];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        statuses = [[NSMutableArray alloc] init];
        FMResultSet *rs = [db executeQuery:@"select * from statuses limit 10"];
        while ([rs next]) {
            NSLog(@"%d %@", [rs intForColumn:@"id"], [rs stringForColumn:@"text"]);
            [statuses addObject:[rs stringForColumn:@"text"]];
        }
        [rs close];  
        [db close];
    }else{
        NSLog(@"Could not open db.");
    }
}

-(void)getTwitterUserTimeline
{ 
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://twitter.com/status/user_timeline/libkinjodev.json"]];
    
    // URLからJSONデータを取得(NSData)
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // JSONで解析するために、NSDataをNSStringに変換。
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // JSONデータをパースする。
    // ここではJSONデータが配列としてパースされるので、NSArray型でデータ取得
    NSArray *jsonrows = [json_string JSONValue];
    
    // DBに接続
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"sample.db"];
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        
        // statuses内の要素を取り出して、確認
        [db beginTransaction];
        for (NSDictionary *status in jsonrows) {
            // You can retrieve individual values using objectForKey on the status NSDictionary
            // This will print the tweet and username to the console
            
            // INSERT
            NSLog(@"INSERT %@", [status objectForKey:@"text"]);
            [db executeUpdate:@"insert into statuses (text) values (?)" , [status objectForKey:@"text"]];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];
        [db close];
    }else{
        NSLog(@"Could not open db.");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    BOOL success;
    NSError *error;	
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"sample.db"];
    success = [fm fileExistsAtPath:writableDBPath];
    if(!success){
        NSLog(@"No sample.db exists");
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sample.db"];
        success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if(!success){
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    NSLog(@"sample.db exists");
    // DB バージョンのチェック
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM schema_migrations where version = ?", @"1"];
        if (![rs next]) {
            // 現バージョンと異なれば create table を実行
            [db beginTransaction];            
            NSLog(@"Create statuses table");
            [db executeUpdate:@"create table statuses(id integer primary key, text varchar(255));"];			
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            NSLog(@"Update schema_migrations");
            [db executeUpdate:@"insert into schema_migrations(version) values (?)" , @"1"];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        [rs close];  
        [db close];
        [self updateStatuses];
    }else{
        NSLog(@"Could not open db.");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [statuses count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* identifier = @"Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if ( nil == cell ) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:identifier];
		[cell autorelease];
		
	}
        
    cell.textLabel.text = [statuses objectAtIndex:indexPath.row];
	return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
    
    NSString *className = @"DetailViewController";
    
    Class class = NSClassFromString( className );
	UIViewController* viewController = [[[class alloc] init] autorelease];
	if ( !viewController ) {
		NSLog( @"%@ was not found.", className );
		return;
	} 
	[self.navigationController pushViewController:viewController animated:YES];
}

-(IBAction)reloadButtonAction:(id)sender{
    
    [self getTwitterUserTimeline];
    [self updateStatuses];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

// arrow for each item
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView 
         accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryDisclosureIndicator;
}


@end
