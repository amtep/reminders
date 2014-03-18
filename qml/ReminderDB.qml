import QtQuick 2.0
import QtQuick.LocalStorage 2.0 as Sql
import Sailfish.Silica 1.0

Item {
    property ListModel model: ListModel { }
    property bool filterDueDate: true
    onFilterDueDateChanged: populateModel()

    property var _db

    // Create and return a string GUID according to RFC 4122
    // (the pseudo-random variant).
    // Relies heavily on Math.random being trustworthy.
    function genGuid() {
        // Get 128 bits of randomy goodness
        var r1 = Math.floor(Math.random() * 0x100000000)
        var r2 = Math.floor(Math.random() * 0x100000000)
        var r3 = Math.floor(Math.random() * 0x100000000)
        var r4 = Math.floor(Math.random() * 0x100000000)
        // Mask out six bits for the fixed-value fields that identify
        // a pseudo-random GUID
        r2 = (4 << 28) | (r2 & 0x0fffffff)  // mandatory version field
        r3 = (2 << 30) | (r3 & 0x3fffffff)  // mandatory variant field
        // Put them all together in the standard string form,
        // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        return r1.toString(16) + "-" + (r2 & 0xffff).toString(16) + "-"
               + (r2 >> 16).toString(16) + "-" + (r3 >> 16).toString(16)
               + "-" + (r3 & 0xffff).toString(16) + r4.toString(16);
    }

    Component.onCompleted: {
        openDb()
        populateModel()
    }

    function _openDbRaw() {
        return Sql.LocalStorage.openDatabaseSync('harbour-reminders', '', 'Reminders', 10000)
    }

    function openDb() {
        _db = _openDbRaw()
        if (_db.version == '') {
            _db.changeVersion('', '1', function (tx) {
                tx.executeSql(
                    "CREATE TABLE reminders ("
                    + "guid TEXT PRIMARY KEY, "
                    + "title TEXT NOT NULL, "
                    + "description TEXT NOT NULL, "
                    + "due TEXT NOT NULL, "
                    + "logic TEXT NOT NULL, "
                    + "logic_value INT NOT NULL)"
                )
                tx.executeSql(
                    "CREATE INDEX reminders_due ON reminders (due)"
                )
                tx.executeSql(
                    "CREATE TABLE history ("
                    + "reminder_guid TEXT NOT NULL "
                    + "REFERENCES reminders (guid) ON DELETE CASCADE, "
                    + "done_date TEXT NOT NULL)"
                )
            });
            // The version change is not reflected in _db (which may
            // be a bug), so reopen it to get the new info.
            _db = _openDbRaw()
        }
    }

    function populateModel() {
        var filter = filterDueDate ? "WHERE due <= date('now')" : ""
        var query = "SELECT * FROM reminders " + filter
            + " ORDER BY due DESC"

        _db.readTransaction(function (tx) {
            model.clear()
            var r = tx.executeSql(query)
            for (var i = 0; i < r.rows.length; i++) {
                var item = r.rows.item(i)
                model.append({
                    "guid": item.guid,
                    "title": item.title,
                    "description": item.description,
                    "dueDate": new Date(item.due),
                    "logic": item.logic,
                    "logicValue": parseInt(item.logic_value, 10)
                })
            }
        })
    }

    function deleteReminder(index) {
        var guid = model.get(index).guid
        _db.transaction(function (tx) {
            tx.executeSql("DELETE FROM reminders WHERE guid = ?", [guid])
        })
        model.remove(index)
    }

    function newReminder(item) {
        var now = new Date()
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        item.guid = genGuid()
        _db.transaction(function (tx) {
            tx.executeSql(
                "INSERT INTO reminders "
                + "(guid, title, description, due, logic, logic_value) "
                + "VALUES (?, ?, ?, ?, ?, ?)",
                [item.guid, item.title, item.description, item.dueDate,
                 item.logic, item.logicValue])
        })
        if (filterDueDate && item.dueDate > today)
            return
        var index = 0
        for ( ; index < model.count; index++) {
            if (model.get(index).dueDate <= newDue)
                break
        }
        model.insert(index, item)
    }

    function editReminder(index, item) {
        var now = new Date()
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        var newDue = item.dueDate

        model.set(index, item)
        if (filterDueDate && newDue > today) {
            model.remove(index)
        } else {
            var newIndex = 0
            for ( ; newIndex < model.count; newIndex++) {
                if (newIndex == index)
                    continue
                if (model.get(newIndex).dueDate <= newDue)
                    break
            }
            if (newIndex > index)
                newIndex--
            if (newIndex != index)
                model.move(index, newIndex, 1)
        }
    }

    function markItemDone(index) {
        var now = new Date()
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        var record = model.get(index)
        var newDue = today
        if (record.logic == "recur") {
            // logic_value is the number of days to advance from today
            newDue.setDate(newDue.getDate() + record.logic_value)
        } else if (record.logic = "weekly") {
            // logic_value is the day of the week (0 = sunday)
            var skip = (record.logic_value - newDue.getDay())
            if (skip <= 0)
                skip += 7
            newDue.setDate(newDue.getDate() + skip)
        } else if (record.logic = "monthly") {
            // logic_value is day of month
            // First see if we have to advance to next month.
            // If we do, go specifically to the 1st of that month,
            // to prevent overflow if the current date is 31st etc.
            if (record.logic_value <= newDue.getDate())
                newDue.setMonth(newDue.getMonth() + 1, 1)
            // Now go to the right day of that month
            newDue.setDate(record.logic_value)
            if (newDue.getDate() < record.logic_value) {
                // current month didn't have that many days
                // newDue must have advanced a month, so go back
                // to last day of prev month
                newDue.setDate(0)
            }
        }
        _db.transaction(function (tx) {
            tx.executeSql("UPDATE reminders SET due = ? WHERE guid = ?",
                [newDue, record.guid])
            tx.executeSql(
                "INSERT INTO history (reminder_guid, done_date)
                    VALUES (?, ?)", [record.guid, today])
        })
        editReminder(index, { "dueDate": newDue })
    }

    function historyModel(index) {
        var guid = model.get(index).guid
        var h_model = _historyModel.createObject(null)
        
        _db.readTransaction(function (tx) {
            h_model.clear()
            var r = tx.executeSql(
                "SELECT done_date FROM history "
                + "WHERE reminder_guid = ? "
                + "ORDER BY done_date DESC",
                [guid])
            for (var i = 0; i < r.rows.length; i++) {
                var item = r.rows.item(i)
                h_model.append({
                    "doneDate": new Date(item.done_date),
                })
            }
        })

        return h_model
    }

    Component {
        id: _historyModel
        ListModel { }
    }
}
