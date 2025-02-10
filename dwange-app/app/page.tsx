import { Button } from "@/components/ui/button";
import { ChevronRight } from "lucide-react";

export default function Home() {
  return (
    <div className="">
      <Button className="h-10 w-auto p-4" variant={"destructive"}>
        Let's Begin <ChevronRight className="aspect-3/1" />
      </Button>
    </div>
  );
}
