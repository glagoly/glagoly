protos = [$client,$bert]; N2O_start();

function closeHelp() {
	qi('help-callout').style.display = 'none';
};

function clearAltForm() {
	qi('alt_text').value = '';
	qi('alt_vote').value = '';
};

$(document).ready(VoteForm.init);
