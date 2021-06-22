import QtQuick 2.0
import QtQuick.LocalStorage 2.12


Item {
    id: root
    property string dbName :"ProjectDetailList"
    property string dbVersion :"1.0"
    property string dbDescription :"Store Project and Command List"
    property int dbEstimatedSize : 1000000
    function getDb(){
        const db = LocalStorage.openDatabaseSync(dbName,
                                                 dbVersion,
                                                 dbDescription,
                                                 dbEstimatedSize)
        db.transaction(tx=>tx.executeSql('CREATE TABLE IF NOT EXISTS ProjectList(projectDir TEXT, projectInitCommand TEXT)'))
        return db
    }


    function getProjectList(){
        const resultJson = []
        try{
            const db = root.getDb()
            db.transaction(function(tx){

                const result = tx.executeSql('SELECT * FROM ProjectList');
                const rows = result.rows
                for(var i=0; i<rows.length; i++){
                    const {projectDir, projectInitCommand} = rows.item(i)
                    resultJson.push({ projectDir, projectInitCommand })
                }
            })
            return { success: true, result: resultJson }
        }catch(err){
            return { success: false, err }
        }

    }

    function saveProjectList(projectListModel){
        try{
            const db = root.getDb()
            db.transaction(function(tx){
                for (var i=0;i< projectListModel.count; i++){
                    const { projectDir, projectInitCommand } = projectListModel.get(i)
                    tx.executeSql('INSERT INTO ProjectList VALUES(?, ?)', [projectDir, projectInitCommand]);
                }
            })

            return { success: true }
        }
        catch(err){
            return { success: false, err }
        }
    }

    function clearProjectList(){
        const db = root.getDb()
        try{
            db.transaction(function(tx){
                tx.executeSql('DELETE FROM ProjectList')
            })
            return { success: true }
        }catch(err){
            return { success: false, err }
        }
    }
}
