import { UserRole } from "@prisma/client";

export type User = {
  id?: string;
  name: string;
  email: string;
  role: UserRole;
  username: string;
  password: string;
  gender: string | null;
};
