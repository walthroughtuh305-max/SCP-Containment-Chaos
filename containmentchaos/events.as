using namespace CB;
using namespace B3D;

#include "main.as"

bool dooropenevent;
bool flippedcamera = false;
bool lightsout = false;

int FakeDeathAnim = -1;

void Hook_ChaosEvent(int randomevent) {
    string eventname;
    int eventchance;
    if (randomevent == 1) {
        if (CB::Difficulty::Current.Name == "Safe") eventchance = Rand(1, 30);
        if (CB::Difficulty::Current.Name == "Euclid") eventchance = Rand(1, 40);
        if (CB::Difficulty::Current.Name == "Keter") eventchance = 0;
        if (eventchance == 1) {
            eventname = "Spawn 096";
            NPC::Create(NPC::Type::SCP096, Player::Collider.GetX(true), Player::Collider.GetY(true), Player::Collider.GetZ(true));
        } else if (eventchance != 1) Hook_ChaosEvent(Rand(RandStart, RandEnd));
    }
    if (randomevent == 2) {
        eventchance = Rand(1, 1);
        if (eventchance == 1) {
            eventname = "Fake death";
            FakeDeathAnim = Rand(0, 1);
            StartTimer(randomevent, 300);
        } else if (eventchance != 1) Hook_ChaosEvent(Rand(RandStart, RandEnd));
    }
    if (randomevent == 3) {
        eventname = "Australia";
        flippedcamera = true;
        StartTimer(randomevent, 3600);
    }
    if (randomevent == 4) {
        eventchance = Rand(1, 3);
        if (eventchance == 1) {
            eventname = "Inverted controls";
            CB::Options::InvertMouse = true;
            StartTimer(randomevent, 1800);
        } else if (eventchance != 1) Hook_ChaosEvent(Rand(RandStart, RandEnd));
    }
    if (randomevent == 5) {
        eventname = "Lights Out";
        lightsout = true;
        StartTimer(randomevent, 1800);
    }
    if (randomevent == 18) {
        eventname = "Open every door the player is closest to";
        dooropenevent = true;
        StartTimer(randomevent, 900);
    }
}

void OnEventTimerComplete(int id) {
    if (id == 2) {
        FakeDeathAnim = -1;
    }
    if (id == 3) {
        flippedcamera = false;
    }
    if (id == 5) {
        lightsout = true;
    }
    if (id == 18) {
        dooropenevent = false;
    }
}
