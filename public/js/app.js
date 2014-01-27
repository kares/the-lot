App = Ember.Application.create();

//App.ApplicationAdapter = DS.LSAdapter.extend({ namespace: 'the-lot' }); // local-storage
//App.ApplicationAdapter = DS.JsonApiAdapter;

App.Serializer = DS.RESTSerializer;
App.TaskSerializer = App.Serializer.extend({
    normalize: function (type, hash, property) {
        // TODO why do we get this messed ... ?!
        if ( hash['task'] ) hash = hash['task'];
        var data = {};
        // normalize the underscored properties
        for (var prop in hash) {
            data[prop.camelize()] = hash[prop];
        }
        return this._super(type, data, property);
    }
});

App.Router.map(function () {
    //this.route("index", { path: "/" });
    this.route("login", { path: "/login" });
    this.resource('tasks', { path: '/' }, function () {
        this.route('active'); this.route('completed');
    });
});

App.TasksRoute = Ember.Route.extend({
    model: function () { return this.store.find('task'); },
    beforeModel: function() {
        if ( ! App.userName ) {
            var self = this;
            $.ajax({ // GET /login
                url: '/login',
                async: false,
                dataType: 'json',
                success: function(data) {
                    App.userName = data['user']['name'];
                },
                error: function() {
                    self.transitionTo('login');
                }
            });
        }
    }
});
App.TasksIndexRoute = Ember.Route.extend({
    setupController: function () {
        this.controllerFor('tasks').set('currentTasks', this.modelFor('tasks'));
    }
});
App.TasksActiveRoute = Ember.Route.extend({
    setupController: function () {
        var tasks = this.store.filter('task', function (task) {
            return ! task.get('completed');
        });
        this.controllerFor('tasks').set('currentTasks', tasks);
    }
});
App.TasksCompletedRoute = Ember.Route.extend({
    setupController: function () {
        var tasks = this.store.filter('task', function (task) {
            return task.get('completed');
        });
        this.controllerFor('tasks').set('currentTasks', tasks);
    }
});

// Task

App.Task = DS.Model.extend({
    name: DS.attr('string'),
    completed: DS.attr('boolean'),

    saveWhenCompletedChanged: function () { this.save(); }.observes('completed')
});

App.TasksController = Ember.ArrayController.extend({
    actions: {
        createTask: function () {
            var name = this.get('newName').trim();
            if ( ! name ) return;

            var task = this.store.createRecord('task', { name: name });
            task.save();

            this.set('newName', '');
        },
        clearCompleted: function () {
            var completed = this.filterProperty('completed', true);
            completed.invoke('deleteRecord');
            completed.invoke('save');
        }
    },

    remaining: function () {
        return this.filterProperty('completed', false).get('length');
    }.property('@each.completed'),

    completed: function () {
        return this.filterProperty('completed', true).get('length');
    }.property('@each.completed')

});

App.TaskController = Ember.ObjectController.extend({
    editMode: false,

    originalName: Ember.computed.oneWay('name'), // for cancelEditing

    actions: {
        editTask: function () { this.set('editMode', true); },

        confirmEdit: function () {
            var originalName = this.get('originalName').trim();

            if ( originalName && originalName.trim() === '' ) {
                return false; // ?
            }
            else {
                var task = this.get('model');
                task.set('name', originalName);
                task.save();
            }

            this.set('originalName', originalName);
            this.set('editMode', false);
        },

        cancelEdit: function () {
            this.set('originalName', this.get('name'));
            this.set('editMode', false);
        },

        removeTask: function () {
            var task = this.get('model');
            task.deleteRecord(); task.save();
        }
    }
});

App.EditTaskView = Ember.TextField.extend({
    focusOnInsert: function () { this.$().focus(); }.on('didInsertElement')
});

Ember.Handlebars.helper('edit-task', App.EditTaskView);

// User/Auth

App.User = Ember.Object.extend({
    username: null, password: null,
    name: function() {
        return this.get('username');
    }.property('username')
});

App.userName = null;

App.LoginController = Ember.ObjectController.extend({
    actions: {
        login: function() {
            var user = this.get('model'); var self = this;
            var data = JSON.stringify({ username: user.get('username'), password: user.get('password') });
            $.post('/login', data).
                done(function() {
                    App.userName = user.get('name');
                    self.transitionToRoute("tasks");
                }).
                fail(function() {
                    // TODO maybe print something
                });
        },
        signup: function() {
            var user = this.get('model'); var self = this;
            var data = JSON.stringify({ username: user.get('username'), password: user.get('password') });
            $.post('/signup', data).
                done(function() {
                    App.userName = user.get('name');
                    self.transitionToRoute("tasks");
                });
        }
    }
});

App.LoginRoute = Ember.Route.extend({
    model: function() { return new App.User; }
});