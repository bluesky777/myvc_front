angular.module('myvcFrontApp')

.directive('loginDialog', ['AUTH_EVENTS', 'App', (AUTH_EVENTS, App)->
	return{
		restrict: 'A'
		templateUrl: '==login/login-form.html'

		#controller: 'LoginCtrl'
		link: (scope)->
			showDialog = ()->
				scope.visible = true


			scope.visible = false;
			scope.$on(AUTH_EVENTS.notAuthenticated, showDialog);
			scope.$on(AUTH_EVENTS.sessionTimeout, showDialog)
	}
])