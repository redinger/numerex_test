// Function to display localized date/time
function displayLocalDT(dt) {
	return (new Date(dt).toString().split(" GMT")[0]);
}