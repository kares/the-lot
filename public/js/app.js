App = Ember.Application.create();

App.ApplicationAdapter = DS.LSAdapter.extend({ namespace: 'the-lot' }); // local-storage

App.Router.map(function () {
    this.resource('tasks', { path: '/' }, function () {
        this.route('active'); this.route('completed');
    });
});

App.TasksRoute = Ember.Route.extend({
    model: function () { return this.store.find('task'); }
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
