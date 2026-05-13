// Quick Bria AI Test - Image Generation Example
// This shows how to use Bria AI to generate an image

const API_KEY = "YOUR_API_KEY_HERE"; // You'll get this after authentication

async function generateImage(prompt, aspectRatio = "1:1") {
  console.log(`Generating: ${prompt}`);
  
  // Step 1: Start generation
  const response = await fetch("https://engine.prod.bria-api.com/v2/image/generate", {
    method: "POST",
    headers: {
      "api_token": API_KEY,
      "Content-Type": "application/json",
      "User-Agent": "BriaSkills/1.3.0"
    },
    body: JSON.stringify({
      prompt: prompt,
      aspect_ratio: aspectRatio,
      sync: true // Wait for result
    })
  });
  
  const data = await response.json();
  
  if (data.result && data.result.image_url) {
    console.log("✓ Image generated:", data.result.image_url);
    return data.result.image_url;
  } else {
    console.error("Error:", data);
    return null;
  }
}

// Example usage
async function main() {
  const imageUrl = await generateImage(
    "Professional product photo of a coffee mug on white background, studio lighting",
    "1:1"
  );
  
  if (imageUrl) {
    console.log("\nYour image is ready! Open this URL:");
    console.log(imageUrl);
  }
}

main();
