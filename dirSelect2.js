/**
 * Directive to apply a select2 plugin to a <select> element
 * Erick Mendoza
 * Martin Xia
 */
angular.module('miniapp').directive('dirSelect2', [
	function () {
	return {
		restrict: 'A',
		scope: {
			'selectAllowClear': '@', //If true, the select2 searchbox will have a button to clear the query. Defaults to false
			'selectWidth': '@', //Width of the selector. Default to 200.
			'ngModel': '=', //Model binded to the select element
		},
		link: function (scope, element, attrs) {
			if (angular.isFunction(element.select2)) {
				//Setting default values for attribute params
				scope.selectWidth = scope.selectWidth || 200;
				scope.selectAllowClear = (scope.selectAllowClear === "true")? true : false;
		
				element.select2({
					allowClear : scope.selectAllowClear,
					width : scope.selectWidth
				});
				
				//On selection, we'll need to re-create the select2 with the new selection
				//as selected value. This is to avoid weird behaviors with
				//angular's two way data binding.
				scope.$watch('ngModel', function(newValue, oldValue){
					//A timeout to apply the change after the digest process is finished
					setTimeout(function(){
						element.select2({
							allowClear : scope.selectAllowClear,
							width : scope.selectWidth
						}).select('val', newValue);
					}, 1);
	            });
			}
		}
	};
}]);