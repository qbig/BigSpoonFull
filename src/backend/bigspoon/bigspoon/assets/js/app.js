$(document).ready(function() {
	function Page() {
		this.model = new app.Model();
		this.view = new app.View();
		this.controller = new app.Controller(this.model, this.view);
		this.controller.initialise(OUTLET_IDS[0]);
	}

	window.page = new Page();

});