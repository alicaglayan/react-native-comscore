
import { NativeModules } from 'react-native';

const { RNComscore } = NativeModules;

class ComScoreTracker {

	constructor(options) {
		RNComscore.init(options);
	}

	trackVideoStreaming(info) {
		console.log('trackVideoStreaming ', info)
		RNComscore.setContentMetaData(info)
	}
	trackVideoPause() {
		console.log('trackVideoPause')
		RNComscore.trackVideoPauseEvent();
	}

}

export default ComScoreTracker;
