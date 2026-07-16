using namespace CB;
using namespace B3D;

float safevalue = 1800;
float euclidvalue = 900;
float ketervalue = 600;

int RandStart = 1;
int RandEnd = 17;

CB::Sound buzz;
Image TimerIcon, TimerMeter;

void Hook_Initialize() {
    buzz = CB::Sound::Load("SFX\\Radio\\Buzz.ogg");
    TimerIcon = LoadImage("GFX\\TimerIcon.png");
    TimerMeter = LoadImage("GFX\\TimerMeter.png");
}

class etimer {
    int id;
    float timeremaining;
    float totalduration;

    etimer(int id, float duration) {
        this.id = id;
        this.timeremaining = duration;
        this.totalduration = duration;
    }
}

array<etimer@> activeetimers;

void StartTimer(int id, float duration) {
    etimer newtimer(id, duration);
    activeetimers.InsertLast(@newtimer);
}

void Hook_Update() {
    if (Menu::IsMainMenuOpen) return;
    if (CB::Difficulty::Current.Name == "Safe" && Menu::IsAnyOpen() == false) {
        if (safevalue > 0) {
            safevalue = safevalue - FPSFactor;
        } 
        if (safevalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(B3D::Rand(RandStart, RandEnd));
            safevalue = 1800;
        }
    } else if (CB::Difficulty::Current.Name == "Euclid" && Menu::IsAnyOpen() == false) {
        if (euclidvalue > 0) {
            euclidvalue = euclidvalue - FPSFactor;
        } 
        if (euclidvalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(B3D::Rand(RandStart, RandEnd));
            euclidvalue = 900;
        }
    } else if (CB::Difficulty::Current.Name == "Keter" && Menu::IsAnyOpen() == false) {
        if (ketervalue > 0) {
            ketervalue = ketervalue - FPSFactor;
        } 
        if (ketervalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(B3D::Rand(RandStart, RandEnd));
            ketervalue = 600;
        }
    }

    for (uint i = 0; i < activeetimers.Length; i++) {
        activeetimers[i].timeremaining -= FPSFactor;

        if (activeetimers[i].timeremaining <= 0) {
            int idfinished = activeetimers[i].id;
            activeetimers.RemoveAt(i);
            i--; 
            OnEventTimerComplete(idfinished);
        }
    }
}

bool Hook_DrawHUD() {
    DrawBar(TimerMeter, 50, 200, 1000, 100 / 100);
    return false;
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
            StartTimer(randomevent, 1000);
        }
    }
    if (randomevent == 3) {
        eventname = "Australia";
    }
}

void OnEventTimerComplete(int id) {
    if (id == 2) {
        CB::Player::KillAnimation = 0;
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
