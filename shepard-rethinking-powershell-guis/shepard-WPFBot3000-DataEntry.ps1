Import-Module WPFBot3000

$values=Dialog {
    TextBox FirstName
    TextBox LastName
    TextBox EmailAddress
    DatePicker ReminderDate
}