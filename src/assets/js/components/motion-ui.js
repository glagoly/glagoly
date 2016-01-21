MotionUI.replace = function(src, dest, animation, remove) {
		var animations = {fade: {in: 'fade-in', out: 'fade-out'}};
		animation = animations[animation];

        MotionUI.animateOut(src, animation.out + ' ease-out', function () {
            src.after(dest);
            MotionUI.animateIn(dest, animation.in + ' ease-out', function() {
            	if (remove) {
            		src.remove();
            	}
            });    
        });
};
