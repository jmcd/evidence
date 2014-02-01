// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Evidence.m instead.

#import "_Evidence.h"

const struct EvidenceAttributes EvidenceAttributes = {
	.createdOnDate = @"createdOnDate",
	.createdOnDateTime = @"createdOnDateTime",
	.dataFilePath = @"dataFilePath",
	.mediaType = @"mediaType",
	.thumbnailImageData = @"thumbnailImageData",
	.type = @"type",
};

const struct EvidenceRelationships EvidenceRelationships = {
};

const struct EvidenceFetchedProperties EvidenceFetchedProperties = {
};

@implementation EvidenceID
@end

@implementation _Evidence

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Evidence" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Evidence";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Evidence" inManagedObjectContext:moc_];
}

- (EvidenceID*)objectID {
	return (EvidenceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdOnDate;






@dynamic createdOnDateTime;






@dynamic dataFilePath;






@dynamic mediaType;






@dynamic thumbnailImageData;






@dynamic type;











@end
