import readFileSync from "fs";

readFileSync("file.txt", "utf8", (err, data) => {
  if (err) throw err;
  console.log(data);
});
