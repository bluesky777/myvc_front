angular.module('myvcFrontApp')


.factory('YearsServ', ['$http', '$q', ($http, $q) ->
	
	years = []

	interfaz = {
		getYears: ()->
			d = $q.defer()

			#console.log 'years.length', years.length
			if years.length > 0
				d.resolve(years)
			else
				$http.get('::years').then((r)->
					years = r.data
					d.resolve(years)
				, (r2)->
					d.reject(r2)
				)

			return d.promise

			
	}
	return interfaz;
])
