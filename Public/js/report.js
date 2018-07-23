function topicChanged(selected) {
    var accessoryIssue = document.getElementById('accessory-issue');
    if (selected == 'issue') {
        accessoryIssue.style.display = 'block';
    } else {
        accessoryIssue.style.display = 'none';
    }
}
