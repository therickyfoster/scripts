(async () => {
  const getBestSrc = (img) => {
    if (img.srcset) {
      const candidates = img.srcset.split(",").map(s => {
        const [url, size] = s.trim().split(" ");
        return { url, width: parseInt(size) || 99999 };
      });
      candidates.sort((a, b) => b.width - a.width);
      return candidates[0].url;
    }
    return img.currentSrc || img.src;
  };

  const imgs = [...document.images];
  let counter = 1;

  for (const img of imgs) {
    try {
      const url = getBestSrc(img);
      const response = await fetch(url);
      const blob = await response.blob();

      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `image_${counter}.${blob.type.split("/")[1] || "jpg"}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(a.href);

      counter++;
    } catch (err) {
      console.error("Failed:", err);
    }
  }

  console.log(`Downloaded ${counter - 1} images.`);
})();
