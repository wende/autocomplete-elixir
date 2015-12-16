module.exports = function extend() {
 var options, name, src, copy, copyIsArray, clone,
   target = arguments[0],
   i = 1,
   length = arguments.length,
   deep = false;

 // Handle a deep copy situation
 if (typeof target === 'boolean') {
   deep = target;
   target = arguments[1] || {};
   // skip the boolean and the target
   i = 2;
 } else if ((typeof target !== 'object' && typeof target !== 'function') || target == null) {
   target = {};
 }

 for (; i < length; ++i) {
   options = arguments[i];
   // Only deal with non-null/undefined values
   if (options != null) {
     // Extend the base object
     for (name in options) {
       src = target[name];
       copy = options[name];

       // Prevent never-ending loop
       if (target !== copy) {
         // Recurse if we're merging plain objects or arrays
         if (deep && copy && (isPlainObject(copy) || (copyIsArray = isArray(copy)))) {
           if (copyIsArray) {
             copyIsArray = false;
             clone = src && isArray(src) ? src : [];
           } else {
             clone = src && isPlainObject(src) ? src : {};
           }

           // Never move original objects, clone them
           target[name] = extend(deep, clone, copy);

         // Don't bring in undefined values
         } else if (typeof copy !== 'undefined') {
           target[name] = copy;
         }
       }
     }
   }
 }

 // Return the modified object
 return target;
};
