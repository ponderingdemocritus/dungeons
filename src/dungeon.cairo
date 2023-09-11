use array::{Array, ArrayTrait};

#[derive(Copy, Drop)]
struct Dungeon {
    seed: u32,
}

#[derive(Copy, Drop, serded)]
struct Settings {
    size: u256,
    length: u256,
    counter: u256
}

#[derive(Copy, Drop)]
struct RoomSettings {
    min_rooms: u256,
    max_rooms: u256,
    min_room_size: u256,
    max_room_size: u256
}

#[derive(Clone, Copy, Drop)]
struct Room {
    x: u32,
    y: u32,
    width: u32,
    height: u32,
}

#[generate_trait]
impl DungeonImpl of DungeonTrait {
    fn settings(self: Dungeon) -> Settings {
        // TOOD: make randomness the same as c&c
        // this takes the seed and returns the settings
        Settings { size: 0, length: 0, counter: 0 }
    }
    fn room_settings(self: Dungeon) -> RoomSettings {
        let min_rooms = self.settings().size / 3;
        let max_rooms = self.settings().size / 1;
        let min_room_size = 2;
        let max_room_size = self.settings().size / 3;
        RoomSettings { min_rooms, max_rooms, min_room_size, max_room_size }
    }
    fn generate_rooms(self: Dungeon) -> (Array<Room>, Array<(u32, u32)>) {
        // TODO impl the keccak256 hash function for the rando - we just use static for now
        let mut num_rooms = 10;
        let mut rooms = array![];
        let mut floor = array![];

        loop {
            if (num_rooms == 0) {
                break;
            }

            let mut new_room = self.generate_random_room();

            if (self.is_room_overlapping(ref new_room, ref rooms)) {
                continue;
            }

            rooms.append(new_room);
            self.populate_floor(ref floor, ref new_room);

            num_rooms -= 1;
        };
        (rooms, floor)
    }
    fn is_room_overlapping(
        self: Dungeon, ref new_room: Room, ref existing_rooms: Array<Room>
    ) -> bool {
        loop {
            match existing_rooms.pop_front() {
                Option::Some(room) => {
                    let current_room_x = room.x;
                    let current_room_y = room.y;
                    let current_room_width = room.width;
                    let current_room_height = room.height;

                    if (new_room.x
                        + new_room.width >= current_room_x && new_room.x <= current_room_x
                        + current_room_width && new_room.y
                        + new_room.height >= current_room_y && new_room.y <= current_room_y
                        + current_room_height) {
                        false;
                    };
                    true;
                },
                Option::None => {
                    break false;
                },
            };
        }
    }
    fn generate_random_room(self: Dungeon) -> Room {
        // TODO: make random values based off seed
        let width = 5;
        let height = 5;
        let x = 10;
        let y = 10;

        Room { x, y, width, height }
    }

    // TOOD: This is Gas thirsty...
    fn populate_floor(self: Dungeon, ref floor: Array<(u32, u32)>, ref room: Room) {
        let mut y_offset = 0;

        // Loop through the height of the room
        loop {
            if y_offset >= room.height {
                break;
            }

            // Calculate the actual y-coordinate based on the room's starting y-coordinate
            let current_y = room.y + y_offset;

            let mut x_offset = 0;

            // Loop through the width of the room
            loop {
                if x_offset >= room.width {
                    break;
                }

                // Calculate the actual x-coordinate based on the room's starting x-coordinate
                let current_x = room.x + x_offset;

                // Insert the current x and y coordinates
                let coordinate = (current_x, current_y);
                floor.append(coordinate);

                // Increment the x_offset
                x_offset += 1;
            };

            // Increment the y_offset
            y_offset += 1;
        }
    }

    // TOOD: Match CC
    fn random(self: Dungeon, min: u32, max: u32) -> u32 {
        (self.seed % (max - min + 1)) + min
    }
}


#[test]
#[available_gas(600000000)]
fn test_dungeon() {
    let dungeon = Dungeon { seed: 123462 };
    let (rooms, floor) = dungeon.generate_rooms();
}
