var bannerboy = bannerboy || {};
bannerboy.main = function() {

	var width = 728;
	var height = 90;
	var banner = bannerboy.createElement({id: "banner", width: width, height: height, backgroundColor: "#fff", overflow: "hidden", cursor: "pointer", parent: document.body});
	var border = bannerboy.createElement({width: "100%", height: "100%", border: "1px solid #000", boxSizing: "border-box", zIndex: 10, parent: banner});
	
	bannerboy.defaults.perspective = 1000;

	var images = [
		"logo_gsuite.png", 
		"white_master.png", 
		"handle_color.png", 
		"long_color.png", 
		"all_color.png", 
		"keyhole.png", 
		"txt_1.png",
		"txt_2.png",
		"txt_3.png",
		"icon_gmail.png", 
		"icon_documents.png", 
		"icon_gdrive.png", 
		"icon_calendar.png", 
		"logo_gsuite.png", 
		"cta_txt.png", 
	];

	bannerboy.preloadImages(images, function() {

		/* Create elements
		================================================= */

		
		var illustration = bannerboy.createElement({left: 405, top: 16, width: 183, height: 58, parent: banner});
			var white_master = bannerboy.createElement({backgroundImage: "white_master.png", retina: true, parent: illustration});
			var handle_color = bannerboy.createElement({backgroundImage: "handle_color.png", retina: true, parent: illustration});
			var long_color = bannerboy.createElement({backgroundImage: "long_color.png", retina: true, parent: illustration});
			var all_color = bannerboy.createElement({backgroundImage: "all_color.png", retina: true, parent: illustration});
			var keyhole = bannerboy.createElement({backgroundImage: "keyhole.png", retina: true, parent: illustration});
		var txt_1 = bannerboy.createElement({backgroundImage: "txt_1.png", left: 155, top: 14, retina: true, parent: banner});
		var txt_2 = bannerboy.createElement({backgroundImage: "txt_2.png", left: 155, top: 24, retina: true, parent: banner});
		var lockupContainer = bannerboy.createElement({left: 470, top: 35, width: 110, height: 24, parent: banner});
			var icon_gmail = bannerboy.createElement({backgroundImage: "icon_gmail.png", left:-443, top: 15, retina: true, parent: lockupContainer});
			var icon_documents = bannerboy.createElement({backgroundImage: "icon_documents.png", top:12, left: -415, retina: true, parent: lockupContainer});
			var icon_gdrive = bannerboy.createElement({backgroundImage: "icon_gdrive.png", left: -377, top: 12, retina: true, parent: lockupContainer});
			var icon_calendar = bannerboy.createElement({backgroundImage: "icon_calendar.png", left: -397, top: 12, retina: true, parent: lockupContainer});
		var logo_gsuite_big = bannerboy.createElement({backgroundImage: "logo_gsuite.png", left: 28, top: 20, retina: true, parent: banner});
		var logo_gsuite = bannerboy.createElement({backgroundImage: "logo.png", left: 135, top: 0, opacity:0, retina: true, parent: lockupContainer});
		var cta = bannerboy.createElement({left: 442, top: 26, width: 109, height: 39, parent: banner});
			var cta_base = bannerboy.createElement({backgroundColor: "#4285f3", width: 100, height: 39, parent: cta});
			var cta_txt = bannerboy.createElement({backgroundImage: "cta_txt.png", left: 15, top: 13, retina: true, parent: cta});
			var txt_3 = bannerboy.createElement({backgroundImage: "txt_3.png", left: -265, top: -3, retina: true, parent: cta});

		/* Adjustments
		================================================= */

		cta_base.set({borderRadius: 2});

		/* Initiate
		================================================= */
		animations();
		timeline();
		interaction();

		/* Animations
		================================================= */
		var main_tl;
		function timeline() {
			// create main_tl here
			main_tl = new BBTimeline()
			.offset(.75)
			.add(banner.lockupIn)
			.add(white_master.in)
			.offset(.75)
			.add(textIn(txt_1))
			.offset(1)
			.add(handle_color.in)
			.chain()
			.add(long_color.in)
			.chain()
			.add(all_color.in)
			.chain()
			.add(keyhole.in)
			.offset(3)
			.add(textOut(txt_1,0.3))
			.offset(.3)
			.add(textIn(txt_2))
			.offset(3)
			.add(textOut(txt_2,0.3))
			.add(white_master.out)
			.offset(.9)
			.add(cta.in)
			.offset(3)
			.loop(1);

			scrubber(main_tl);
		}

		function animations() {

			handle_color.in = new BBTimeline()
			.from(handle_color, 0.5, {opacity: 0});

			long_color.in = new BBTimeline()
			.from(long_color, 0.5, {opacity: 0});

			all_color.in = new BBTimeline()
			.from(all_color, 0.5, {opacity: 0});

			keyhole.in = new BBTimeline()
			.from(keyhole, 0.5, {opacity: 0});

			banner.lockupIn = new BBTimeline()
			.staggerFrom([icon_gmail, icon_documents, icon_gdrive, icon_calendar].reverse(), 1, {cycle: {x: function (i) { return -10 * bannerboy.utils.map((i+1), 1, 5, 5, 1); }}, ease: Power2.easeOut}, 0.2)
			.staggerFrom([icon_gmail, icon_documents, icon_gdrive, icon_calendar].reverse(), 0.3, {opacity: 0}, 0.2)
			.offset(0.5)
			.from(logo_gsuite_big, 1, {x: 10, opacity: 0})
			.from(logo_gsuite, 1, {x: 0, opacity: 0});

			cta.in = new BBTimeline()
			.from(cta, 1, {opacity: 0, y: 0, ease: Power2.easeOut});

			white_master.in = new BBTimeline()
			.from(white_master, 0.5, {opacity: 1});

			white_master.out = new BBTimeline()
			.to([white_master,handle_color, long_color, all_color, keyhole, txt_2], 0.5, {opacity: 0});

		}

		function textIn(txt) {
			return new BBTimeline()
			.from(txt, 0.5, {opacity: 0, ease: Power1.easeInOut});
		}
		
		function textOut(txt, duration) {
			return new BBTimeline()
			.to(txt, duration || 0.5, {opacity: 0, ease: Power1.easeInOut});
		}


		/* Interactions
		================================================= */
		function interaction() {
			// click logic goes here
			banner.onclick = function() {
				Enabler.exit("Clickthrough");
			};
		}

		/* Helpers
		================================================= */

		/* Scrubber
		================================================= */
		function scrubber(tl) {
			if (window.location.origin == "file://") {
				bannerboy.include(["../bannerboy_scrubber.min.js"], function() {
					if (bannerboy.scrubberController) bannerboy.scrubberController.create({"main timeline": tl});
				});
			}
		}
	});
};