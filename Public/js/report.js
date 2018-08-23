function topicChanged(selected) {
    var accessoryIssue = document.getElementById('accessory-issue');
    var appIssue = document.getElementById('app-issue');
    if (selected == 'accessory-issue') {
        accessoryIssue.style.display = 'block';
        appIssue.style.display = 'none';
    } else if (selected == 'app-issue') {
        appIssue.style.display = 'block';
        accessoryIssue.style.display = 'none';
    } else {
        appIssue.style.display = 'none';
        accessoryIssue.style.display = 'none';
    }
}
