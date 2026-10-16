// --
// var/http/htdocs/js/Core.Customer.FileManagerToPortal.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --
"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.FileManagerToPortal = (function (TargetNS) {

   TargetNS.Init = function (Element) {
        var Baselink =  window.location.protocol + "//" + window.location.host + window.location.pathname + '?Action=CustomerPortalFileManager;';    
        var URL = Baselink + 'Subaction=ViewFileMagener;File='+Element;

        Core.UI.Popup.OpenPopup(URL, 'Viewer', 'Default');
        return false;
            
   };

   return TargetNS;
}( Core.Customer.FileManagerToPortal  || {}));
