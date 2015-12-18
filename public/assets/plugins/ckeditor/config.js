/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
        config.skin = 'office2013';
        config.filebrowserBrowseUrl         = base_url+'skins/acp/assets/plugins/ckfinder/ckfinder.html';
	config.filebrowserImageBrowseUrl    = base_url+'skins/acp/assets/plugins/ckfinder/ckfinder.html?type=Images';
	config.filebrowserFlashBrowseUrl    = base_url+'skins/acp/assets/plugins/ckfinder/ckfinder.html?type=Flash';
	config.filebrowserUploadUrl         = base_url+'skins/acp/assets/plugins/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Files';
	config.filebrowserImageUploadUrl    = base_url+'skins/acp/assets/plugins/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images';
	config.filebrowserFlashUploadUrl    = base_url+'skins/acp/assets/plugins/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Flash';
};
