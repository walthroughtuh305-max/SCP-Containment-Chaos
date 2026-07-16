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

bool Hook_DrawHUD() {
    
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

// DrawBar implemented by mashelux
// Note that this is for the timer bar only (TimerMeter), TimerIcon doesn't use this function
// img: The image you want as a bar, in this case should be TimerMeter
// x, y: Where the bar is positioned
// width: Self explanatory
// filled: How much filled is the bar (100 = full, 0 = depleted)
// centerX: Unsure what this does, but in CB its set to false most of the time
void DrawBar(Image img, int x, int y, int width, int filled, bool centerX = false) {
    int spacing = img.Width + 2;
    width = int(width / spacing) * spacing + 3;
    
    int height = img.Height + 6;

    if (centerX) {
        x -= width / 2; 
    }

    SetColor(255, 255, 255);
    Rect(x, y, width, height, 0);

    for (int i = 1; i < int(((width - 6) * filled) / spacing); i++) {
        img.Draw(x + 3 + spacing * (i - 1), y + 3);
    }
}
