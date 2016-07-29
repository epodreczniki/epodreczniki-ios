







#import "EPDatabaseModel.h"

@interface EPDatabaseModel ()

@property (nonatomic, strong) FMDatabase *db;

- (FMResultSet *)executeQueryWithString:(NSString *)query andList:(va_list)args;
- (int)executeNonQueryWithString:(NSString *)query andList:(va_list)args;

@end

@implementation EPDatabaseModel

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        self.lastInsertedRowId = -1;
    }
    return self;
}

- (void)dealloc {
    self.db = nil;
}

- (FMDatabase *)openDatabase {
#if DEBUG_DATABASE

    if (self.db) {

    }
#endif

    self.lastInsertedRowId = -1;

    NSString *dbPath = [self.configuration.pathModel pathForDatabaseFile];

    FMDatabase *db = [[FMDatabase alloc] initWithPath:dbPath];
#if DEBUG_DATABASE
    db.traceExecution = YES;
#endif
    db.logsErrors = YES;
    db.crashOnErrors = YES;
    
#if DEBUG_DATABASE

#endif

    if ([db open]) {
        self.db = db;
        return db;
    }
    
    return nil;
}

- (void)closeDatabase {
    [self.db close];
    self.db = nil;
    
#if DEBUG_DATABASE

#endif
}

#pragma mark - Private methods

- (FMResultSet *)executeQueryWithString:(NSString *)query andList:(va_list)args {
    NSAssert(query, @"Query cannot be nil");
    FMDatabase *db = [self openDatabase];
    if (db) {
        FMResultSet *resultSet = [db executeQuery:query withVAList:args];
        return resultSet;
    }
    return nil;
}

- (int)executeNonQueryWithString:(NSString *)query andList:(va_list)args {
    NSAssert(query, @"Query cannot be nil");
    int affected = -1;
    FMDatabase *db = [self openDatabase];
    if (db) {
        [db executeUpdate:query withVAList:args];
        affected = [db changes];
        self.lastInsertedRowId = [db lastInsertRowId];
        [self closeDatabase];
    }
    return affected;
}

@end

@implementation EPDatabaseModel (ExecutingQueries)

#pragma mark - Public methods

- (FMResultSet *)executeQueryWithString:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    FMResultSet *rs = [self executeQueryWithString:format andList:ap];
    va_end(ap);
    return rs;
}

- (FMResultSet *)executeQueryWithName:(NSString *)name, ... {
    va_list ap;
    va_start(ap, name);
    FMResultSet *rs = [self executeQueryWithString:[self queryForName:name] andList:ap];
    va_end(ap);
    return rs;
}

- (int)executeNonQueryWithString:(NSString *)format, ... {
    int affected = -1;
    va_list ap;
    va_start(ap, format);
    affected = [self executeNonQueryWithString:format andList:ap];
    va_end(ap);
    return affected;
}

- (int)executeNonQueryWithName:(NSString *)name, ... {
    int affected = -1;
    va_list ap;
    va_start(ap, name);
    affected = [self executeNonQueryWithString:[self queryForName:name] andList:ap];
    va_end(ap);
    return affected;
}

- (long long)executeNonQueryWithNameAndGetId:(NSString *)name, ... {
    long long lastId = -1;
    va_list ap;
    va_start(ap, name);
    [self executeNonQueryWithString:[self queryForName:name] andList:ap];
    lastId = self.lastInsertedRowId ;

    va_end(ap);
    return lastId;
}

- (BOOL)boolForName:(NSString *)name, ... {
    va_list ap;
    va_start(ap, name);
    FMResultSet *rs = [self executeQueryWithString:[self queryForName:name] andList:ap];
    va_end(ap);
    BOOL result = NO;
    if ([rs next]) {
        result = [rs boolForColumnIndex:0];
    }
    [rs close];
    [self closeDatabase];
    return result;
}

- (int)intForName:(NSString *)name, ... {
    va_list ap;
    va_start(ap, name);
    FMResultSet *rs = [self executeQueryWithString:[self queryForName:name] andList:ap];
    va_end(ap);
    int result = 0;
    if ([rs next]) {
        result = [rs intForColumnIndex:0];
    }
    [rs close];
    [self closeDatabase];
    return result;
}

- (double)doubleForName:(NSString *)name, ... {
    va_list ap;
    va_start(ap, name);
    FMResultSet *rs = [self executeQueryWithString:[self queryForName:name] andList:ap];
    va_end(ap);
    double result = 0.0;
    if ([rs next]) {
        result = [rs doubleForColumn:0];
    }
    [rs close];
    [self closeDatabase];
    return result;
}

- (NSString *)stringForName:(NSString *)name, ... {
    va_list ap;
    va_start(ap, name);
    FMResultSet *rs = [self executeQueryWithString:[self queryForName:name] andList:ap];
    va_end(ap);
    NSString *result = nil;
    if ([rs next]) {
        result = [rs stringForColumnIndex:0];
    }
    [rs close];
    [self closeDatabase];
    return result;
}


- (NSString *)getBestFitFormat:(NSString *)contentID withMethod:(NSString*)method {
    NSString* findFormat = @"ZIP-480";
    
    FMResultSet *rs = [self executeQueryWithName:method, contentID];
    while ([rs next]) {

        NSString *format = [rs stringForColumn:@"format"];
        if ([NSObject isNull:format]) {
            continue;
        }
        format = [format uppercaseString];

        findFormat = format;

        if ([UIDevice currentDevice].isIPad) {
            if ([format isEqualToString:@"ZIP-1440"]) {
                break;
            }
        }
        else {
            if ([format isEqualToString:@"ZIP-980"]) {
                break;
            }
        }
        
    }

    [rs close];
    [self closeDatabase];
    
    return findFormat;
}

- (NSString *)getBestFitFormatForCollection:(NSString *)contentID {
    return [self getBestFitFormat:contentID withMethod:@"get_collection_formats"];
}

- (NSString *)getBestFitFormatForRootId:(NSString *)rootId {
    return [self getBestFitFormat:rootId withMethod:@"get_collection_formats_by_rootId"];
}

@end

@implementation EPDatabaseModel (NamedQueries)

static NSMutableDictionary *namedQueries = nil;

- (NSString *)queryForName:(NSString *)name {

    if (!namedQueries) {
        namedQueries = [NSMutableDictionary new];

        [namedQueries setObject:@"insert into ep_collection(root_id, content_id, title, abstract, school_id, subject_id, published, md_version, ep_version, \
                        language, license, created, revised, cover, cover_thumb, link, for_tablets_only, recipient, content_status, cover_type, institution, \
                        subtitle, stylesheet) \
                        values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                        forKey:@"insert_collection"];
        [namedQueries setObject:@"insert into ep_collection_author(content_id, id, first_name, surname, institution, email, full_name) values (?, ?, ?, ?, ?, ?, ?)"
                        forKey:@"insert_collection_author"];
        [namedQueries setObject:@"insert into ep_collection_format(content_id, url, format, size) values (?, ?, ?, ?)"
                        forKey:@"insert_collection_format"];
        [namedQueries setObject:@"insert into ep_collection_keyword(content_id, name) values (?, ?)"
                        forKey:@"insert_collection_keyword"];
        [namedQueries setObject:@"insert into ep_collection_school(content_id, id, education_level, class, education_order) values (?, ?, ?, ?, ?)"
                        forKey:@"insert_collection_school"];
        [namedQueries setObject:@"insert into ep_collection_subject(content_id, id, name, json) values (?, ?, ?, ?)"
                        forKey:@"insert_collection_subject"];

        [namedQueries setObject:@"delete from ep_collection where content_id = ?"
                        forKey:@"remove_collection"];
        [namedQueries setObject:@"delete from ep_collection_author where content_id = ?"
                        forKey:@"remove_collection_author"];
        [namedQueries setObject:@"delete from ep_collection_format where content_id = ?"
                        forKey:@"remove_collection_format"];
        [namedQueries setObject:@"delete from ep_collection_keyword where content_id = ?"
                        forKey:@"remove_collection_keyword"];
        [namedQueries setObject:@"delete from ep_collection_school where content_id = ?"
                        forKey:@"remove_collection_school"];
        [namedQueries setObject:@"delete from ep_collection_subject where content_id = ?"
                        forKey:@"remove_collection_subject"];

        [namedQueries setObject:@"select root_id from ep_store_collection where root_id = ?"
                        forKey:@"get_root_id_from_store_collections"];
        [namedQueries setObject:@"insert into ep_store_collection(root_id) values (?)"
                        forKey:@"add_root_id_to_store_collection"];
        [namedQueries setObject:@"update ep_store_collection set api_content_id = ? where root_id = ?"
                        forKey:@"set_api_content_id_in_store_collection"];
        [namedQueries setObject:@"select * from ep_store_collection where root_id = ?"
                        forKey:@"get_raw_store_collection"];

        [namedQueries setObject:@"update ep_store_collection set in_api = 0"
                        forKey:@"mark_all_store_collection_as_not_in_api"];
        [namedQueries setObject:@"update ep_store_collection set in_api = 1 where root_id = ?"
                        forKey:@"mark_store_collection_as_in_api_by_root_id"];
        [namedQueries setObject:@"select root_id, api_content_id from ep_store_collection \
                        where in_api = 0 and store_content_id is null and store_tmp_id is null"
                        forKey:@"get_orphaned"];
        [namedQueries setObject:@"delete from ep_store_collection where root_id = ?"
                        forKey:@"remove_store_collection"];
        [namedQueries setObject:@"select root_id, api_content_id from ep_store_collection \
                        where in_api = 0 and ( \
                            (store_content_id is not null and store_content_id != api_content_id) or \
                            (store_tmp_id     is not null and store_tmp_id     != api_content_id) \
                        )"
                        forKey:@"get_orphaned_stored"];
        [namedQueries setObject:@"update ep_store_collection set api_content_id = ifnull(store_content_id, store_tmp_id) where root_id = ?"
                        forKey:@"prevent_updating_removed_collections"];

        [namedQueries setObject:@"select c.root_id, c.content_id, c.title, c.cover, c.cover_thumb, c.subtitle, s.education_level, s.class, cs.id as subject_id, cs.name as subject_name \
                       from ep_collection c, \
                            ep_store_collection sc \
                            left outer join ep_collection_school s on (s.content_id = c.content_id) \
                            left outer join ep_collection_subject cs on (cs.content_id = c.content_id) \
                       where cs.content_id = c.content_id and ifnull(sc.store_content_id, sc.api_content_id) = c.content_id \
                       ORDER BY CAST(cs.json AS INTEGER)   \
                       --order by cs.education_order asc, c.title asc"
                       forKey:@"get_textbooks_for_tablets"];
        [namedQueries setObject:@"select c.root_id, c.content_id, c.title, c.cover, c.cover_thumb, c.subtitle, s.education_level, s.class, cs.id as subject_id, cs.name as subject_name \
                       from ep_collection c, \
                            ep_store_collection sc \
                            left outer join ep_collection_school s on (s.content_id = c.content_id) \
                            left outer join ep_collection_subject cs on (cs.content_id = c.content_id) \
                       where cs.content_id = c.content_id and ifnull(sc.store_content_id, sc.api_content_id) = c.content_id and c.for_tablets_only = 0 \
                        ORDER BY CAST(cs.json AS INTEGER)   \
                       --order by cs.education_order asc, c.title asc"
                       forKey:@"get_textbooks_for_phones"];
        [namedQueries setObject:@"select c.root_id, c.content_id, c.title, c.cover, c.cover_thumb, c.subtitle, s.education_level, s.class, cs.id as subject_id, cs.name as subject_name \
                       from ep_collection c, \
                            ep_store_collection sc \
                            left outer join ep_collection_school s on (s.content_id = c.content_id) \
                            left outer join ep_collection_subject cs on (cs.content_id = c.content_id) \
                       where cs.content_id = c.content_id and ifnull(sc.store_content_id, sc.api_content_id) = c.content_id and c.content_id = ?"
                       forKey:@"textbook_for_content_id"];
        [namedQueries setObject:@"select c.root_id, c.content_id, c.title, c.abstract, c.published, c.md_version, c.ep_version, c.language, c.license, c.created, c.revised, \
                        c.cover, c.cover_thumb, c.link, c.for_tablets_only, c.recipient, c.content_status, c.cover_type, \
                        c.subtitle, c.institution, c.stylesheet, \
                        cs.name as subject_name, cs.id as subject_id, s.class, s.education_level, cf.url as format_zip_link, cf.size as format_zip_size \
                        from ep_collection c \
                        left outer join ep_collection_school s on (c.content_id = s.content_id ) \
                        left outer join ep_collection_subject cs on (c.content_id = cs.content_id), \
                        ep_collection_format cf \
                        where cf.content_id = c.content_id and c.content_id = ? AND cf.format = ?"
                        forKey:@"get_collection"];
        [namedQueries setObject:@"select ca.full_name from ep_collection_author ca \
                        where ca.content_id = ?"
                        forKey:@"get_collection_authors"];

        [namedQueries setObject:@"SELECT first_name AS role_type, full_name, email FROM ep_collection_author \
                                WHERE content_id = ? ORDER BY CAST(email AS INTEGER);"
                         forKey:@"get_collection_authors_with_roles"];
        [namedQueries setObject:@"SELECT url,  format,  size, json  \
                                FROM ep_collection_format \
                                where content_id = ?"
                         forKey:@"get_collection_formats"];
        [namedQueries setObject:@"SELECT f.url,  f.format,  f.size, f.json   \
                                    FROM ep_store_collection sc, ep_collection_format f  \
                                where f.content_id = sc.api_content_id and sc.root_id = ?"
                         forKey:@"get_collection_formats_by_rootId"];

        [namedQueries setObject:@"select sc.root_id, sc.api_content_id, sc.store_content_id, sc.store_tmp_id, \
                               sc.store_completed, ifnull(sc.store_url, cf.url) as store_url, sc.store_path, cf.size as api_size \
                               from ep_store_collection sc, ep_collection_format cf \
                               where cf.content_id = sc.api_content_id and sc.root_id = ? and cf.format = ?"
                        forKey:@"get_store_textbook"];
        [namedQueries setObject:@"update ep_store_collection set store_content_id = null, store_tmp_id = null, store_completed = null, \
                               store_url = null, store_path = null where root_id = ?"
                        forKey:@"store_remove_textbook_by_id"];
        [namedQueries setObject:@"update ep_store_collection set store_tmp_id = ?, store_completed = ?, store_url = ? where root_id = ?"
                        forKey:@"store_set_textbook_downloading"];
        [namedQueries setObject:@"update ep_store_collection set store_content_id = ?, store_tmp_id = null, store_completed = ?,\
                        store_url = null, store_path = ? where root_id = ?"
                        forKey:@"store_set_textbook_normal"];
        [namedQueries setObject:@"update ep_store_collection set store_tmp_id = ?, store_completed = ?, store_url = ? where root_id = ?"
                        forKey:@"store_set_textbook_updating"];
        [namedQueries setObject:@"select root_id from ep_store_collection where store_completed = 0 limit 1"
                        forKey:@"get_first_store_textbook_root_id_for_download"];

        [namedQueries setObject:@"select value, 0 as priority from ep_user_settings \
                                where user_id = ? and key = ? union select ?, 1 order by priority asc"
                        forKey:@"settings_get_value"];
        [namedQueries setObject:@"delete from ep_user_settings where user_id = ? and key = ?"
                        forKey:@"settings_remove_value"];
        [namedQueries setObject:@"insert into ep_user_settings (user_id, key, value) values (?, ?, ?)"
                        forKey:@"settings_set_value"];
        [namedQueries setObject:@"select value from ep_user_settings where user_id = ? and key = ?"
                        forKey:@"settings_get_value2"];
        [namedQueries setObject:@"delete from ep_user_settings where user_id = ?"
                        forKey:@"settings_remove_all_by_user_id"];

        [namedQueries setObject:@"select value, 0 as priority from ep_collection_state \
                                where root_id = ? and content_id = ? and key = ? union select ?, 1 order by priority asc"
                        forKey:@"collection_state_get_value"];
        [namedQueries setObject:@"delete from ep_collection_state where root_id = ? and content_id = ? and key = ?"
                        forKey:@"collection_state_remove_value"];
        [namedQueries setObject:@"insert into ep_collection_state (root_id, content_id, key, value) values (?, ?, ?, ?)"
                        forKey:@"collection_state_set_value"];
        [namedQueries setObject:@"select value from ep_collection_state where root_id = ? and content_id = ? and key = ?"
                        forKey:@"collection_state_get_value2"];
        [namedQueries setObject:@"delete from ep_collection_state where root_id = ? and key = ?"
                        forKey:@"collection_state_remove_all_by_root_id"];
        [namedQueries setObject:@"delete from ep_collection_state where content_id = ? and key = ?"
                        forKey:@"collection_state_remove_all_by_user_id"];

        [namedQueries setObject:@"insert into ep_user(login, role, state, avatar, question,\nspassword, hpassword, sanswer, hanswer, created_date, last_login_date)\nvalues (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                        forKey:@"ep_user_create_user"];
        [namedQueries setObject:@"select id, login, role, state, avatar, question, spassword,\nhpassword, sanswer, hanswer, created_date, last_login_date\nfrom ep_user where id = ?"
                        forKey:@"ep_user_read_user"];
        [namedQueries setObject:@"update ep_user set login = ?, role = ?, state = ?, avatar = ?,\nquestion = ?, spassword = ?, hpassword = ?, sanswer = ?, hanswer = ?,\ncreated_date = ?, last_login_date = ?\nwhere id = ?"
                        forKey:@"ep_user_update_user"];
        [namedQueries setObject:@"delete from ep_user where id = ?"
                        forKey:@"ep_user_delete_user"];
        [namedQueries setObject:@"select id, login, role, state, avatar, question,\nspassword, hpassword, sanswer, hanswer,\ncreated_date, last_login_date\nfrom ep_user order by role desc, lower(login) asc"
                        forKey:@"ep_user_get_all_users_by_type"];
        [namedQueries setObject:@"select id, login, role, state, avatar, question,\nspassword, hpassword, sanswer, hanswer,\ncreated_date, last_login_date\nfrom ep_user order by lower(login) asc"
                        forKey:@"ep_user_get_all_users_by_name"];
        [namedQueries setObject:@"select count(*) from ep_user"
                        forKey:@"ep_user_users_count"];
        [namedQueries setObject:@"select exists(select * from ep_user where lower(login) = ?)"
                         forKey:@"ep_user_name_available"];

        [namedQueries setObject:@"INSERT INTO ep_user_notes (localUserId, handbookId, moduleId, pageId, noteId, userId, location, subject, value, type, accepted, referenceTo, referencedBy, modifyTime, json) \
                                values (?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?)"
                         forKey:@"ep_note_create_note"];
        [namedQueries setObject:@"UPDATE ep_user_notes SET \
                                localUserId=?, handbookId=?, moduleId=?, pageId=?, noteId=?, userId=?, location=?, subject=?, value=?, type=?, accepted=?, referenceTo=?, referencedBy=?, modifyTime=?, json=? \
                                WHERE localNoteId = ?"
                         forKey:@"ep_note_update_note"];
        [namedQueries setObject:@"DELETE FROM ep_user_notes \
                                WHERE localNoteId = ?"
                         forKey:@"ep_note_delete_note"];
        [namedQueries setObject:@"SELECT localNoteId, localUserId, handbookId, moduleId, pageId, noteId, userId, location, subject, value, type, accepted, referenceTo, referencedBy, modifyTime, json \
                                FROM ep_user_notes \
                                WHERE pageId = ? and localUserId = ?"
                         forKey:@"ep_note_get_note_by_page"];
        [namedQueries setObject:@"SELECT localNoteId, localUserId, handbookId, moduleId, pageId, noteId, userId, location, subject, value, type, accepted, referenceTo, referencedBy, modifyTime, json \
                                FROM ep_user_notes \
                                WHERE \
                                (type = 4 OR type = 5 OR type = 6) AND \
                                handbookId = ? and localUserId = ? "
                         forKey:@"ep_note_get_notes_by_handbookId"];
        [namedQueries setObject:@"SELECT localNoteId, localUserId, handbookId, moduleId, pageId, noteId, userId, location, subject, value, type, accepted, referenceTo, referencedBy, modifyTime, json \
                                FROM ep_user_notes \
                                WHERE \
                                (type = 0 OR type = 1 OR type = 2 OR type = 3) AND \
                                handbookId = ? and localUserId = ?"
                         forKey:@"ep_note_get_bookmarks_by_handbookId"];
        
        [namedQueries setObject:@"SELECT localNoteId, localUserId, handbookId, moduleId, pageId, noteId, userId, location, subject, value, type, accepted, referenceTo, referencedBy, modifyTime, json \
                            FROM ep_user_notes \
                            WHERE localNoteId = ?"
                         forKey:@"ep_note_get_note_by_localId"];
        
        [namedQueries setObject:@"SELECT localNoteId, localUserId, handbookId, moduleId, pageId, noteId, userId, location, subject, value, type, accepted, referenceTo, referencedBy, modifyTime, json \
         FROM ep_user_notes \
         WHERE localNoteId = ?"
                         forKey:@"ep_note_get_bookmark_by_localId"];
        
        
        
        [namedQueries setObject:@"DELETE FROM ep_user_notes WHERE localUserId = ?"
                         forKey:@"ep_note_delete_by_user_id"];
        [namedQueries setObject:@"DELETE FROM ep_user_notes WHERE handbookId = ?"
                         forKey:@"ep_note_delete_by_handbook_id"];

        [namedQueries setObject:@"SELECT womi_state FROM ep_user_womi_state WHERE user_id = ? AND root_id = ? AND womi_id = ?"
                         forKey:@"ep_user_womi_state_get_data"];
        [namedQueries setObject:@"INSERT INTO ep_user_womi_state(user_id, root_id, womi_id, womi_state) VALUES (?, ?, ?, ?)"
                         forKey:@"ep_user_womi_state_set_data"];
        [namedQueries setObject:@"DELETE FROM ep_user_womi_state WHERE user_id = ? AND root_id = ? AND womi_id = ?"
                         forKey:@"ep_user_womi_state_delete"];
        
        
        
        
        [namedQueries setObject:@"DELETE FROM ep_user_womi_state WHERE user_id = ?"
                         forKey:@"ep_user_womi_state_delete_by_user_id"];
        [namedQueries setObject:@"DELETE FROM ep_user_womi_state WHERE root_id = ?"
                         forKey:@"ep_user_womi_state_delete_by_root_id"];
    }
    
    return namedQueries[name];
}

@end
