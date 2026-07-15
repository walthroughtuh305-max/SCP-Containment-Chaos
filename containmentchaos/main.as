using namespace CB;
using namespace B3D;

float safevalue = 1800;
float euclidvalue = 900;
float ketervalue = 600;

float timer = 0.6;

CB::Sound buzz;

void Hook_Initialize() {
    buzz = CB::Sound::Load("SFX\\Radio\\Buzz.ogg");
}

void Hook_Update() {
    if (Menu::IsMainMenuOpen) return;
    if (CB::Difficulty::Current.Name == "Safe") {
        if (safevalue > 0) {
            safevalue = safevalue - timer;
        } 
        if (safevalue <= 0) {
            buzz.Play();
            safevalue = 1800;
        }
    } else if (CB::Difficulty::Current.Name == "Euclid") {
        if (euclidvalue > 0) {
            euclidvalue = euclidvalue - timer;
        } 
        if (euclidvalue <= 0) {
            buzz.Play();
            euclidvalue = 900;
        }
    } else if (CB::Difficulty::Current.Name == "Keter") {
        if (ketervalue > 0) {
            ketervalue = ketervalue - timer;
        } 
        if (ketervalue <= 0) {
            buzz.Play();
            ketervalue = 600;
        }
    }
}