## 1.4 Image and Video Generation Models

**Image generation models** create images from text descriptions or other inputs.  
**Video generation models** produce video content based on textual prompts or other media inputs.

**Applications**: Content creation, Design, Entertainment, Advertising, and more.

![Image and Video Generation](../assets/Basics_of_Generative_AI/01-llms-embeddings-models/veo-3-ai-text-to-video.gif)
*Modern video generation models can create realistic videos from text prompts.*

### Open-source Image and Video Generation Models

- **Z-AI**: GLM-Image
- **Black forest Labs**: Flux 2 Klein
- **Alibaba**: Qwen-Image-Layered

📚 [Explore more open-source image and video generation models](https://huggingface.co/models)

### Closed-source Image and Video Generation Models

- **OpenAI**: GPT image 1.5, GPT image 1.0, Sora 2 Pro
- **Google**: Gemini 3.1 Flash Image, Veo 3.1
- **Grok**: Grok Imagine Image, Grok Imagine Video
- **Qwen**: Qwen Image 2.0, WAN Video 2.6
---

## To improve your image generation results, follow these best practices:

- **Be specific**: More details give you more control. For example, instead of "fantasy armor," try "ornate elven plate armor, etched with silver leaf patterns, with a high collar and pauldrons shaped like falcon wings."

- **Provide context and intent**: Explain the purpose of the image to help the model understand the context. For example, "Create a logo for a high-end, minimalist skincare brand" works better than "Create a logo."

- **Iterate and refine**: Don't expect a perfect image on your first attempt. Use follow-up prompts to make small changes, for example, "Make the lighting warmer" or "Change the character's expression to be more serious."

- **Use step-by-step instructions**: For complex scenes, split your request into steps. For example, "First, create a background of a serene, misty forest at dawn. Then, in the foreground, add a moss-covered ancient stone altar. Finally, place a single, glowing sword on top of the altar."

- **Describe what you want, not what you don't**: Instead of saying "no cars", describe the scene positively by saying, "an empty, deserted street with no signs of traffic."

- **Control the camera**: Guide the camera view. Use photographic and cinematic terms to describe the composition, for example, "wide-angle shot", "macro shot", or "low-angle perspective".

- **Prompt for images**: Describe the intent by using phrases such as "create an image of" or "generate an image of". Otherwise, the multimodal model might respond with text instead of the image.

- **Pass Thought Signatures**: When using Gemini 3 Pro Image, we recommend that you pass thought signatures back to the model during multi-turn image creation and editing. This lets you preserve reasoning context across interactions. For code samples related to multi-turn image editing using Gemini 3 Pro Image, see Example of multi-turn image editing using thought signatures.


## Video Generation Best Practices

[Google VEO Video generation best practices](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/video/best-practices)


*Now that you understand the basics of image generation models, let's explore video generation models in the next section.*

---

[← Previous: Text-to-Speech (TTS) and Speech-to-Text (STT) Models](13-tts-and-stt.md) | [Next: Multi-modal Capabilities →](15-multimodal-capabilities.md)

[← Back to Index](README.md)
