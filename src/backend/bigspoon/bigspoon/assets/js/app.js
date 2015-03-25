$(document).ready(function () {

    function Page() {
        this.model = new app.Model();
        this.view = new app.View();
        this.controller = new app.Controller(this.model, this.view);
        this.controller.initialise(OUTLET_IDS[0]);
        this.pageShown = true;
        var that = this;
        $(document).on({
            'show.visibility': function() {
                if (!that.pageShown){
                    window.location.reload(false);//reload from cache
                }
            },
            'hide.visibility': function() {
                that.pageShown = false;
            }
        });
    }

    window.page = new Page();
});