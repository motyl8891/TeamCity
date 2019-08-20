@isTest
private class DNPageControllerTest{
    
    @isTest static void testRunAs() { 
        DNPageController runAsTest = new DNPageController();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userWithoutCC = new User(Alias = 'standt', Email='MrNoCallCenter@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='MrNoCallCenter', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = p.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='MrNoCallCenter@testorg.com');
        System.runAs(userWithoutCC) {       
            runAsTest.initialize();
            System.assertEquals(true,runAsTest.ccNotFound);
            System.assertEquals(false,runAsTest.ccFound);
        }        
        User userWithCcNoPermissionSet = new User(Alias = 'standt', Email='MrCallCenter@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='MrCallCenter', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='MrCallCenterNoPS@testorg.com', CallCenterId = '04v0O000000L1IhQAK');       
        System.runAs(userWithCcNoPermissionSet) {
            runAsTest.initialize();
            System.assertEquals(false,runAsTest.ccNotFound);
            System.assertEquals(true,runAsTest.ccFound);
            System.assertEquals(false,runAsTest.hasPermission);
        }   
        
        User userWithCcWithPermissionSet = new User(Alias = 'standt', Email='MrCallCenter@testorg.com', 
                                                    EmailEncodingKey='UTF-8', LastName='MrCallCenter', LanguageLocaleKey='en_US', 
                                                    LocaleSidKey='en_US', ProfileId = p.Id, 
                                                    TimeZoneSidKey='America/Los_Angeles', UserName='MrCallCenterPS@testorg.com', CallCenterId = '04v0O000000L1IhQAK');
        insert userWithCcWithPermissionSet;
        PermissionSet pr = new PermissionSet(Label='Test Permission Set',Name='Test_Permission_Set');
        insert pr;  
        PermissionSetAssignment pm = new PermissionSetAssignment(AssigneeId=userWithCcWithPermissionSet.id,PermissionSetId=pr.id);
        insert pm;    
        System.runAs(userWithCcWithPermissionSet) {      
            runAsTest.ccId = [SELECT CallCenterId FROM USER WHERE id =: userinfo.getUserId()].CallCenterId;  
            runAsTest.checkPermissionSet = [SELECT AssigneeId, Assignee.username FROM PermissionSetAssignment WHERE PermissionSet.id= :pr.id AND AssigneeId= :userWithCcWithPermissionSet.id];   
            runAsTest.callCenterCheck();
            System.assertEquals(false,runAsTest.ccNotFound);
            System.assertEquals(true,runAsTest.ccFound);
            System.assertEquals(true,runAsTest.hasPermission);
        } 
    }
    
    @isTest static void testLists() {
        DNPageController limitTest = new DNPageController();
        limitTest.getlimitNumbers();
        System.assertEquals(10,limitTest.limitNumber);
    }
    
    @isTest static void testSetFirstPage() {
        DNPageController sortTest = new DNPageController();
        sortTest.setFirstPage();
        System.assertEquals(0,sortTest.offsetNumber);
        System.assertEquals(1,sortTest.currPageNumber);
    }
    
    @isTest static void testRefresh() {
        DNPageController refreshTestDesc = new DNPageController();
        refreshTestDesc.runQuery();            
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId  AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY Id DESC LIMIT :limitNumber',refreshTestDesc.query);
        refreshTestDesc.moveOperation='NEXT';     
        refreshTestDesc.runQuery();            
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND Id <= :lastRecord AND (id < :lastId OR Id <> :lastRecord) AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY Id DESC LIMIT :limitNumber',refreshTestDesc.query);
        refreshTestDesc.moveOperation='PREV';
        refreshTestDesc.runQuery();            
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND Id >= :firstRecord AND (id > :firstId OR Id <> :firstRecord) AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY Id NULLS FIRST, id LIMIT :limitNumber',refreshTestDesc.query);       
        DNPageController refreshTestAsc = new DNPageController();
        refreshTestAsc.moveOperation='NEXT';     
        refreshTestAsc.descending= 'DESC, id DESC';    
        refreshTestAsc.orderColumn = 'name';    
        refreshTestAsc.runQuery();            
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND name <= :lastRecord AND (id < :lastId OR name <> :lastRecord) AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY name DESC, id DESC LIMIT :limitNumber',refreshTestAsc.query);       
        refreshTestAsc.moveOperation='NEXT';     
        refreshTestAsc.descending= ', id';    
        refreshTestAsc.orderColumn = 'name';
        refreshTestAsc.runQuery();          
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND name >= :lastRecord AND (id > :lastId OR name <> :lastRecord) AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY name , id LIMIT :limitNumber',refreshTestAsc.query);       
        refreshTestAsc.moveOperation='PREV';
        refreshTestAsc.descending= 'DESC, id DESC';    
        refreshTestAsc.orderColumn = 'name';    
        refreshTestAsc.runQuery();            
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND name >= :firstRecord AND (id > :firstId OR name <> :firstRecord) AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY name NULLS FIRST, id LIMIT :limitNumber',refreshTestAsc.query);       
        refreshTestAsc.moveOperation='PREV';
        refreshTestAsc.descending= ', id';    
        refreshTestAsc.orderColumn = 'name';
        refreshTestAsc.runQuery();            
        System.assertEquals('SELECT Name, Phone, Description FROM AdditionalNumber WHERE CallCenterId = :ccId AND name <= :firstRecord AND (id < :firstId OR name <> :firstRecord) AND (Name LIKE :searchText OR Phone LIKE :searchText OR Description Like :searchText) ORDER BY name DESC NULLS LAST, id DESC LIMIT :limitNumber',refreshTestAsc.query);                     
        DNPageController tableShowTest = new DNPageController();        
        List<AdditionalNumber> additionalNumbersList1 =  new List<AdditionalNumber>();
        String query = 'Select id from AdditionalNumber limit 0';
        additionalNumbersList1=database.query(query);
        tableShowTest.tableVisibility(additionalNumbersList1);            
        System.assertEquals(true, tableShowTest.noMatch);
        System.assertEquals(false, tableShowTest.Match);
        List<AdditionalNumber> additionalNumbersList2 =  new List<AdditionalNumber>{
            new AdditionalNumber(Id='04m9E000000CaSZQA0', Name='Andrzej Makala', Phone='+41123123451', Description='a'), 
                new AdditionalNumber(Id='04m9E000000CaSaQAK', Name='Michal Materla', Phone='+41123123452', Description='b'), 
                new AdditionalNumber(Id='04m9E000000CaSbQAK', Name='Zbigniew Kisiala', Phone='+41123123453', Description='c')
                };
                    tableShowTest.tableVisibility(additionalNumbersList2);            
        System.assertEquals(false, tableShowTest.noMatch);
        System.assertEquals(true, tableShowTest.Match);        
    }
    
    @isTest static void testsetOffset() {
        DNPageController offsetTest = new DNPageController();
        List<AdditionalNumber> additionalNumbersList =  new List<AdditionalNumber>{
            new AdditionalNumber(Id='04m9E000000CaSZQA0', Name='Andrzej Makala', Phone='+41123123451', Description='a'), 
                new AdditionalNumber(Id='04m9E000000CaSaQAK', Name='Michal Materla', Phone='+41123123452', Description='b'), 
                new AdditionalNumber(Id='04m9E000000CaSbQAK', Name='Zbigniew Kisiala', Phone='+41123123453', Description='c')
                };
                    offsetTest.setOffset(additionalNumbersList);
        
        System.assertEquals('04m9E000000CaSZQA0',offsetTest.firstRecord);
        System.assertEquals('04m9E000000CaSbQAK',offsetTest.lastRecord);
        
        offsetTest.orderColumn = 'name';
        offsetTest.setOffset(additionalNumbersList);
        System.assertEquals('Andrzej Makala',offsetTest.firstRecord);
        System.assertEquals('Zbigniew Kisiala',offsetTest.lastRecord);
        
        offsetTest.orderColumn = 'phone';
        offsetTest.setOffset(additionalNumbersList);	       
        System.assertEquals('+41123123451',offsetTest.firstRecord);
        System.assertEquals('+41123123453',offsetTest.lastRecord);
        
        offsetTest.orderColumn = 'description';
        offsetTest.setOffset(additionalNumbersList);	       
        System.assertEquals('a',offsetTest.firstRecord);
        System.assertEquals('c',offsetTest.lastRecord);
    }
    
    
    @isTest static void testPrevious() {       
        DNPageController prevTest = new DNPageController();
        prevTest.offsetNumber = 10;
        prevTest.currPageNumber = 2;
        prevTest.previous();
        System.assertEquals(1,prevTest.currPageNumber);
        System.assertEquals(0,prevTest.offsetNumber);
    }
    
    @isTest static void testNext() {
        DNPageController nextTest = new DNPageController();
        nextTest.currPageNumber = 2;
        nextTest.totalPageNumber = 10;       
        nextTest.offsetNumber = 10;   
        nextTest.next();
        System.assertEquals(3,nextTest.currPageNumber);
        System.assertEquals(20,nextTest.offsetNumber);       
    }
    
    @isTest static void testButtonShowing() {
        DNPageController buttonsTest = new DNPageController();
        buttonsTest.buttonsShowing();
        System.assertEquals(false,buttonsTest.showPrevious);
        
        buttonsTest.currPageNumber = 2;
        buttonsTest.totalPageNumber = 2;
        buttonsTest.buttonsShowing();
        System.assertEquals(true,buttonsTest.showPrevious);
        System.assertEquals(false,buttonsTest.showNext);
        
        buttonsTest.currPageNumber = 1;
        buttonsTest.totalPageNumber = 1;
        buttonsTest.buttonsShowing();
        System.assertEquals(false,buttonsTest.showPrevious);
        System.assertEquals(false,buttonsTest.showNext);
        
        buttonsTest.currPageNumber = 2;
        buttonsTest.totalPageNumber = 3;
        buttonsTest.buttonsShowing();
        System.assertEquals(true,buttonsTest.showPrevious);
        System.assertEquals(true,buttonsTest.showNext);
        
    }
    
    @isTest static void testSortingNamePhone() {
        DNPageController sortTest = new DNPageController();
        //sort by Name
        sortTest.sortParam = 'Name'; 
        //First click - sort by name ascending
        sortTest.sorting();
        System.assertEquals(0,sortTest.sortPhone);
        System.assertEquals(0,sortTest.sortDescription);
        System.assertEquals('',sortTest.arrowPhone);
        System.assertEquals('',sortTest.arrowDescription);
        System.assertEquals(String.fromCharArray( new List<integer> {9650}),sortTest.arrowName);
        System.assertEquals('name',sortTest.orderColumn);
        System.assertEquals(', id',sortTest.descending);
        System.assertEquals(1,sortTest.sortName);
        
        //Second click - sort by name descending
        sortTest.sorting();
        System.assertEquals(String.fromCharArray( new List<integer> {9660}),sortTest.arrowName);
        System.assertEquals('name',sortTest.orderColumn);
        System.assertEquals('DESC, id DESC',sortTest.descending);
        System.assertEquals(2,sortTest.sortName);
        
        //Third click - reset sort, default sort by id
        sortTest.sorting();
        System.assertEquals('',sortTest.arrowName);
        System.assertEquals('Id',sortTest.orderColumn);
        System.assertEquals('DESC',sortTest.descending);
        System.assertEquals(0,sortTest.sortName);
        
        //sort by Phone
        sortTest.sortParam = 'Phone'; 
        //First click - sort by phone ascending
        sortTest.sorting();
        System.assertEquals(0,sortTest.sortName);
        System.assertEquals(0,sortTest.sortDescription);
        System.assertEquals('',sortTest.arrowName);
        System.assertEquals('',sortTest.arrowDescription);
        System.assertEquals(String.fromCharArray( new List<integer> {9650}),sortTest.arrowPhone);
        System.assertEquals('phone',sortTest.orderColumn);
        System.assertEquals(', id',sortTest.descending);
        System.assertEquals(1,sortTest.sortPhone);
        
        //Second click - sort by phone descending
        sortTest.sorting();
        System.assertEquals(String.fromCharArray( new List<integer> {9660}),sortTest.arrowPhone);
        System.assertEquals('phone',sortTest.orderColumn);
        System.assertEquals('DESC, id DESC',sortTest.descending);
        System.assertEquals(2,sortTest.sortPhone);
        
        //Third click - reset sort, default sort by id
        sortTest.sorting();
        System.assertEquals('',sortTest.arrowPhone);
        System.assertEquals('Id',sortTest.orderColumn);
        System.assertEquals('DESC',sortTest.descending);
        System.assertEquals(0,sortTest.sortPhone);
        
    }
    
    @isTest static void testSortingDescription() {
        DNPageController sortTest = new DNPageController();
        //Sort by Description
        sortTest.sortParam = 'Description'; 
        //First click - sort by name ascending
        sortTest.sorting();
        System.assertEquals(0,sortTest.sortName);
        System.assertEquals(0,sortTest.sortPhone);
        System.assertEquals('',sortTest.arrowName);
        System.assertEquals('',sortTest.arrowPhone);
        System.assertEquals(String.fromCharArray( new List<integer> {9650}),sortTest.arrowDescription);
        System.assertEquals('Description',sortTest.orderColumn);
        System.assertEquals('NULLS FIRST, id',sortTest.descending);
        System.assertEquals(1,sortTest.sortDescription);
        
        //Second click - sort by name descending
        sortTest.sorting();
        System.assertEquals(String.fromCharArray( new List<integer> {9660}),sortTest.arrowDescription);
        System.assertEquals('Description',sortTest.orderColumn);
        System.assertEquals('DESC NULLS LAST, id DESC',sortTest.descending);
        System.assertEquals(2,sortTest.sortDescription);
        
        //Third click - reset sort, default sort by id
        sortTest.sorting();
        System.assertEquals('',sortTest.arrowDescription);
        System.assertEquals('Id',sortTest.orderColumn);
        System.assertEquals('DESC',sortTest.descending);
        System.assertEquals(0,sortTest.sortDescription);       
        System.assertEquals(0,sortTest.offsetNumber);
        System.assertEquals(1,sortTest.currPageNumber);
    }
    
    @isTest static void testaddRecord() {
        DNPageController addRecordTest = new DNPageController();
        addRecordTest.addRecord();
        System.assertEquals('',addRecordTest.directoryName);
        System.assertEquals('',addRecordTest.directoryPhone);
        System.assertEquals(false,addRecordTest.pageMess);             
    }
    
    @isTest static void testClearFields() {
        DNPageController clearFieldsTest = new DNPageController();
        clearFieldsTest.clearFields();
        System.assertEquals('',clearFieldsTest.directoryName);
        System.assertEquals('',clearFieldsTest.directoryPhone);
        System.assertEquals('',clearFieldsTest.directoryDescription);    
    }    
    
}