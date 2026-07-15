using namespace CB;
using namespace B3D;

float safevalue = 1800;
float euclidvalue = 900;
float ketervalue = 600;

float timer = 0.6f;

CB::Sound buzz;

void Hook_Initialize() {
    buzz = CB::Sound::Load("SFX\\Radio\\Buzz.ogg");
}

void Hook_Update() {
    if (Menu::IsMainMenuOpen) return;
    if (CB::Difficulty::Current.Name == "Safe" && Menu::IsAnyOpen() == false) {
        if (safevalue > 0) {
            safevalue = safevalue - timer;
        } 
        if (safevalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(B3D::Rand(1, 5));
            safevalue = 1800;
        }
    } else if (CB::Difficulty::Current.Name == "Euclid" && Menu::IsAnyOpen() == false) {
        if (euclidvalue > 0) {
            euclidvalue = euclidvalue - timer;
        } 
        if (euclidvalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(B3D::Rand(1, 5));
            euclidvalue = 900;
        }
    } else if (CB::Difficulty::Current.Name == "Keter" && Menu::IsAnyOpen() == false) {
        if (ketervalue > 0) {
            ketervalue = ketervalue - timer;
        } 
        if (ketervalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(B3D::Rand(1, 17));
            ketervalue = 600;
        }
    }
}

void Hook_ChaosEvent(int randomevent) {
    string eventname;
    int eventchance;
    if (randomevent == 1) {
        eventname = "Spawn 096";
        NPC::Create(NPC::Type::SCP096, Player::Collider.GetX(true), Player::Collider.GetY(true), Player::Collider.GetZ(true));
    }
    if (randomevent == 2) {
        eventchance = B3D::Rand(1, 5);
        if (eventchance == 1) {
            eventname = "Fake death";
            CB::Player::KillAnimation = 1;
            float eventtimer = 240;
        }
    }
    if (randomevent == 3) {
        eventname = "Australia";
    }
}
