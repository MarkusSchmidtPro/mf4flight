
	IStore
		open
		backup
		close
	
	
	DataProvider<T>		- store connector
		List<T> fetchAllAsync()
				fetchActiveAsync
				getById
				saveChangesAsync (insert/update)
				softDelete
				rawSaveAsync



--> data_model_core (independent from store)

	SyncRecord
		syncId
		recordVersion
		
		: DatabaseRecord 
			loadFromJson
			isDirty
			ensureActive
			softDelete
			equals
			
			: IDataModel
				copyTo
				equal
		